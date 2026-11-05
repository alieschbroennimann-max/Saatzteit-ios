# Ergaenzt das frisch erzeugte iOS-Projekt um alles, was der App Store verlangt (der Ordner ios/ entsteht bei jedem Bau neu):
#   1. Datenschutz-Manifest PrivacyInfo.xcprivacy nach ios/App/App kopieren und als Ressource der App eintragen
#   2. Info.plist: ITSAppUsesNonExemptEncryption = NO (Saatzeit nutzt keine eigene Verschluesselung,
#      sonst fragt App Store Connect bei jedem Build nach den Exportbestimmungen)
#   3. Mindestversion iOS 15 fuer App und Plugins: Die Vorlage von Capacitor 7 verlangt iOS 14,
#      Xcode 27 baut dafuer nicht mehr. Passt die Podfile an und fuehrt danach "pod install" aus.
#      Ausserdem Skript-Sandboxing aus, sonst darf das Kopierskript von CocoaPods nicht laufen.
#   4. Versionsnummer der App (MARKETING_VERSION) aus package.json, z. B. 1.1.0. Passend dazu APP_VERSION in www/index.html.
#   5. Scene-Lebenszyklus: ios-extras/SceneDelegate.swift und UIApplicationSceneManifest in der Info.plist.
#      Ab iOS 27 beendet iOS Apps ohne Scenes sofort beim Start.
# Aufruf nach "npx cap add ios" im Ordner saatzeit-ios:  ruby scripts/ios-setup.rb
# Braucht das Gem "xcodeproj" (kommt mit CocoaPods mit). Kann beliebig oft laufen.

require "fileutils"
begin
  require "xcodeproj"
rescue LoadError
  # Mac mit Homebrew: Die Ruby von macOS hat xcodeproj nicht, CocoaPods bringt es mit. Mit dessen Ruby neu starten.
  brew_ruby, pods_gems = "/opt/homebrew/opt/ruby/bin/ruby", "/opt/homebrew/opt/cocoapods/libexec"
  if ENV["SAATZEIT_RERUN"].nil? && File.exist?(brew_ruby) && File.directory?(pods_gems)
    exec({ "GEM_PATH" => pods_gems, "SAATZEIT_RERUN" => "1" }, brew_ruby, __FILE__, *ARGV)
  end
  abort "Gem xcodeproj fehlt: CocoaPods installieren (Mac: brew install cocoapods) oder gem install xcodeproj."
end

root = File.expand_path("..", __dir__)
app_dir = File.join(root, "ios", "App", "App")
project_path = File.join(root, "ios", "App", "App.xcodeproj")
abort "iOS-Projekt fehlt: zuerst npx cap add ios ausfuehren." unless File.directory?(project_path)

# 1. Datenschutz-Manifest
FileUtils.cp(File.join(root, "ios-extras", "PrivacyInfo.xcprivacy"), File.join(app_dir, "PrivacyInfo.xcprivacy"))
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == "App" } or abort "Ziel App nicht gefunden."
group = project.main_group.children.find { |g| g.respond_to?(:path) && g.path == "App" } || project.main_group
ref = group.files.find { |f| f.path == "PrivacyInfo.xcprivacy" } || group.new_reference("PrivacyInfo.xcprivacy")
unless target.resources_build_phase.files_references.include?(ref)
  target.resources_build_phase.add_file_reference(ref, true)
end
# 5. Scene-Lebenszyklus (ab iOS 27 Pflicht, sonst beendet iOS die App beim Start): SceneDelegate.swift eintragen
FileUtils.cp(File.join(root, "ios-extras", "SceneDelegate.swift"), File.join(app_dir, "SceneDelegate.swift"))
scene_ref = group.files.find { |f| f.path == "SceneDelegate.swift" } || group.new_reference("SceneDelegate.swift")
unless target.source_build_phase.files_references.include?(scene_ref)
  target.source_build_phase.add_file_reference(scene_ref, true)
end
# Mindestversion im App-Projekt (Schritt 3, Plugins weiter unten)
MIN_IOS = "15.0"
(project.build_configurations + project.targets.flat_map(&:build_configurations)).each do |config|
  config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = MIN_IOS
  # Neuere Xcode-Versionen schalten das Skript-Sandboxing ein (auch als «empfohlene Einstellung» beim Öffnen).
  # Dann darf das Kopierskript von CocoaPods (Pods-App-frameworks.sh) nicht laufen und der Bau bricht ab.
  config.build_settings["ENABLE_USER_SCRIPT_SANDBOXING"] = "NO"
end
# Xcode 27 meldet Anfuehrungszeichen-Includes in den Headern von CapacitorCordova als Fehler. Pruefung aus
# (nur auf Projektebene, auf dem Ziel App wuerde es die Einstellung von CocoaPods ueberdecken).
project.build_configurations.each { |c| c.build_settings["CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER"] = "NO" }
target.build_configurations.each { |c| c.build_settings.delete("CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER") }
# 4. Versionsnummer
require "json"
version = JSON.parse(File.read(File.join(root, "package.json")))["version"]
target.build_configurations.each { |config| config.build_settings["MARKETING_VERSION"] = version }
project.save
puts "PrivacyInfo.xcprivacy liegt in ios/App/App und ist im Projekt eingetragen."
puts "App-Projekt: iOS #{MIN_IOS} als Mindestversion, Version #{version}"

# 2. Exportbestimmungen
plist_path = File.join(app_dir, "Info.plist")
abort "Info.plist fehlt: #{plist_path}" unless File.file?(plist_path)
plist = Xcodeproj::Plist.read_from_path(plist_path)
plist["ITSAppUsesNonExemptEncryption"] = false
# 5. Scene-Manifest: ein Fenster, Main.storyboard wie bisher, SceneDelegate aus ios-extras
plist["UIApplicationSceneManifest"] = {
  "UIApplicationSupportsMultipleScenes" => false,
  "UISceneConfigurations" => {
    "UIWindowSceneSessionRoleApplication" => [{
      "UISceneConfigurationName" => "Default Configuration",
      "UISceneDelegateClassName" => "$(PRODUCT_MODULE_NAME).SceneDelegate",
      "UISceneStoryboardFile" => "Main"
    }]
  }
}
Xcodeproj::Plist.write_to_path(plist, plist_path)
puts "Info.plist: ITSAppUsesNonExemptEncryption = NO, Scene-Manifest mit SceneDelegate"

# 3. Mindestversion fuer die Plugins: Podfile anpassen, dann Pods neu einrichten
podfile_path = File.join(root, "ios", "App", "Podfile")
podfile = File.read(podfile_path)
updated = podfile.sub(/^platform :ios, '[\d.]+'/, "platform :ios, '#{MIN_IOS}'")
# Frueheren Saatzeit-Block entfernen und in aktueller Form neu eintragen
updated = updated.gsub(/  # Saatzeit: Mindestversion.*?\n  end\n/m, "")
updated = updated.sub("  assertDeploymentTarget(installer)\n",
  "  assertDeploymentTarget(installer)\n" \
  "  # Saatzeit: Mindestversion und Xcode-27-Anpassung, eingetragen von scripts/ios-setup.rb\n" \
  "  installer.pods_project.targets.each do |t|\n" \
  "    t.build_configurations.each do |c|\n" \
  "      c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '#{MIN_IOS}' if c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < #{MIN_IOS}\n" \
  "      c.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'\n" \
  "    end\n" \
  "  end\n")
File.write(podfile_path, updated) if updated != podfile
# Immer ausfuehren, damit auch ein abgebrochener frueherer Lauf nachgeholt wird. Eigene Gem-Pfade nicht vererben.
pod_env = { "GEM_PATH" => nil, "GEM_HOME" => nil, "RUBYOPT" => nil }
pod_env["LANG"] = "en_US.UTF-8" unless ENV["LANG"].to_s.include?("UTF-8")
system(pod_env, "pod", "install", chdir: File.dirname(podfile_path)) or abort "pod install ist fehlgeschlagen."
puts "Plugins: iOS #{MIN_IOS} als Mindestversion"
