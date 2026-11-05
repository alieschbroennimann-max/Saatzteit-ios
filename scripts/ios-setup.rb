# Ergaenzt das frisch erzeugte iOS-Projekt um alles, was der App Store verlangt (der Ordner ios/ entsteht bei jedem Bau neu):
#   1. Datenschutz-Manifest PrivacyInfo.xcprivacy nach ios/App/App kopieren und als Ressource der App eintragen
#   2. Info.plist: ITSAppUsesNonExemptEncryption = NO (Saatzeit nutzt keine eigene Verschluesselung,
#      sonst fragt App Store Connect bei jedem Build nach den Exportbestimmungen)
#   3. Mindestversion iOS 15 fuer App und Plugins: Die Vorlage von Capacitor 7 verlangt iOS 14,
#      Xcode 27 baut dafuer nicht mehr. Passt die Podfile an und fuehrt danach "pod install" aus.
#      Ausserdem Skript-Sandboxing aus, sonst darf das Kopierskript von CocoaPods nicht laufen.
#   4. Versionsnummer der App (MARKETING_VERSION) aus package.json, z. B. 1.1.0. Passend dazu APP_VERSION in www/index.html.
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
# Mindestversion im App-Projekt (Schritt 3, Plugins weiter unten)
MIN_IOS = "15.0"
(project.build_configurations + project.targets.flat_map(&:build_configurations)).each do |config|
  config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = MIN_IOS
  # Neuere Xcode-Versionen schalten das Skript-Sandboxing ein (auch als «empfohlene Einstellung» beim Öffnen).
  # Dann darf das Kopierskript von CocoaPods (Pods-App-frameworks.sh) nicht laufen und der Bau bricht ab.
  config.build_settings["ENABLE_USER_SCRIPT_SANDBOXING"] = "NO"
end
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
Xcodeproj::Plist.write_to_path(plist, plist_path)
puts "Info.plist: ITSAppUsesNonExemptEncryption = NO"

# 3. Mindestversion fuer die Plugins: Podfile anpassen, dann Pods neu einrichten
podfile_path = File.join(root, "ios", "App", "Podfile")
podfile = File.read(podfile_path)
updated = podfile.sub(/^platform :ios, '[\d.]+'/, "platform :ios, '#{MIN_IOS}'")
unless updated.include?("Saatzeit: Mindestversion")
  updated = updated.sub("  assertDeploymentTarget(installer)\n",
    "  assertDeploymentTarget(installer)\n" \
    "  # Saatzeit: Mindestversion, eingetragen von scripts/ios-setup.rb\n" \
    "  installer.pods_project.targets.each do |t|\n" \
    "    t.build_configurations.each do |c|\n" \
    "      c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '#{MIN_IOS}' if c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < #{MIN_IOS}\n" \
    "    end\n" \
    "  end\n")
end
File.write(podfile_path, updated) if updated != podfile
# Immer ausfuehren, damit auch ein abgebrochener frueherer Lauf nachgeholt wird. Eigene Gem-Pfade nicht vererben.
pod_env = { "GEM_PATH" => nil, "GEM_HOME" => nil, "RUBYOPT" => nil }
pod_env["LANG"] = "en_US.UTF-8" unless ENV["LANG"].to_s.include?("UTF-8")
system(pod_env, "pod", "install", chdir: File.dirname(podfile_path)) or abort "pod install ist fehlgeschlagen."
puts "Plugins: iOS #{MIN_IOS} als Mindestversion"
