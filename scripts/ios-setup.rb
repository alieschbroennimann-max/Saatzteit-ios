# Ergaenzt das frisch erzeugte iOS-Projekt (Capacitor 8, Swift Package Manager) um alles, was Saatzeit und der
# App Store verlangen. Der Ordner ios/ entsteht bei jedem Bau neu, darum stehen die Anpassungen hier:
#   1. Datenschutz-Manifest PrivacyInfo.xcprivacy nach ios/App/App kopieren und als Ressource der App eintragen
#   2. Info.plist: ITSAppUsesNonExemptEncryption = NO (Saatzeit nutzt keine eigene Verschluesselung,
#      sonst fragt App Store Connect bei jedem Build nach den Exportbestimmungen)
#   3. iPhone und iPad (TARGETED_DEVICE_FAMILY = 1,2). iPhone nur Hochformat, iPad in alle Richtungen. iOS 15.
#   4. Versionsnummer (MARKETING_VERSION) und Build-Nummer (CURRENT_PROJECT_VERSION) aus package.json
#      ("version", z. B. 1.2.0, und "build", z. B. 3). Passend dazu APP_VERSION in www/index.html.
#      Vor jedem Upload zu Apple die Build-Nummer erhoehen: npm run build:next
#   5. Xcode 27 meldet Anfuehrungszeichen-Includes im Cordova-Teil von Capacitor als Fehler: diese Pruefung aus.
#   6. Signier-Team fuer Bauten auf dem eigenen Mac aus ios-team.txt (nicht auf GitHub, siehe .gitignore), falls vorhanden.
# Den Scene-Lebenszyklus (ab iOS 27 Pflicht) bringt die Vorlage von Capacitor 8 selbst mit.
# Aufruf nach "npx cap add ios" im Ordner saatzeit-ios:  ruby scripts/ios-setup.rb
# Braucht das Gem "xcodeproj" (kommt mit CocoaPods mit, sonst: gem install xcodeproj). Kann beliebig oft laufen.

require "fileutils"
require "json"
begin
  require "xcodeproj"
rescue LoadError
  # Mac mit Homebrew: Die Ruby von macOS hat xcodeproj nicht, CocoaPods bringt es mit. Mit dessen Ruby neu starten.
  brew_ruby, pods_gems = "/opt/homebrew/opt/ruby/bin/ruby", "/opt/homebrew/opt/cocoapods/libexec"
  if ENV["SAATZEIT_RERUN"].nil? && File.exist?(brew_ruby) && File.directory?(pods_gems)
    exec({ "GEM_PATH" => pods_gems, "SAATZEIT_RERUN" => "1" }, brew_ruby, __FILE__, *ARGV)
  end
  abort "Gem xcodeproj fehlt: gem install xcodeproj (oder auf dem Mac: brew install cocoapods)."
end

root = File.expand_path("..", __dir__)
app_dir = File.join(root, "ios", "App", "App")
project_path = File.join(root, "ios", "App", "App.xcodeproj")
abort "iOS-Projekt fehlt: zuerst npx cap add ios ausfuehren." unless File.directory?(project_path)

project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == "App" } or abort "Ziel App nicht gefunden."
group = project.main_group.children.find { |g| g.respond_to?(:path) && g.path == "App" } || project.main_group

# 1. Datenschutz-Manifest
FileUtils.cp(File.join(root, "ios-extras", "PrivacyInfo.xcprivacy"), File.join(app_dir, "PrivacyInfo.xcprivacy"))
ref = group.files.find { |f| f.path == "PrivacyInfo.xcprivacy" } || group.new_reference("PrivacyInfo.xcprivacy")
unless target.resources_build_phase.files_references.include?(ref)
  target.resources_build_phase.add_file_reference(ref, true)
end

# 3. iPhone und iPad, iOS 15 / 4. Versions- und Build-Nummer
MIN_IOS = "15.0"
pkg = JSON.parse(File.read(File.join(root, "package.json")))
version, build = pkg["version"], pkg["build"].to_i
abort "package.json: \"build\" fehlt oder ist kleiner als 1." if build < 1
(project.build_configurations + target.build_configurations).each do |config|
  config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = MIN_IOS
end
target.build_configurations.each do |config|
  config.build_settings["TARGETED_DEVICE_FAMILY"] = "1,2"
  config.build_settings["MARKETING_VERSION"] = version
  config.build_settings["CURRENT_PROJECT_VERSION"] = build.to_s
end
# 6. Team (Personal Team), damit Xcode nach einem Neuaufbau von ios/ nicht nachfragt
team_file = File.join(root, "ios-team.txt")
team = File.file?(team_file) ? File.read(team_file).strip : ""
target.build_configurations.each { |c| c.build_settings["DEVELOPMENT_TEAM"] = team } unless team.empty?
# 5. Xcode 27: Anfuehrungszeichen-Includes in Framework-Headern nicht als Fehler werten
project.build_configurations.each { |c| c.build_settings["CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER"] = "NO" }
project.save
puts "PrivacyInfo.xcprivacy liegt in ios/App/App und ist im Projekt eingetragen."
puts "App-Projekt: iPhone und iPad, iOS #{MIN_IOS} als Mindestversion, Version #{version} (Build #{build})"

# Alte Platzhalter-Startbilder der Vorlage entfernen, sobald capacitor-assets eigene erzeugt hat
# (sonst warnt Xcode: The image set "Splash" has 3 unassigned children)
splash_dir = File.join(app_dir, "Assets.xcassets", "Splash.imageset")
if Dir.glob(File.join(splash_dir, "Default@*")).any?
  Dir.glob(File.join(splash_dir, "splash-2732x2732*.png")).each { |f| File.delete(f) }
end

# 2. Exportbestimmungen / 3. Ausrichtung: iPhone nur Hochformat, iPad alle vier Richtungen
#    (iPad-Apps sollen sich drehen lassen, sonst funktioniert Split View nicht)
plist_path = File.join(app_dir, "Info.plist")
abort "Info.plist fehlt: #{plist_path}" unless File.file?(plist_path)
plist = Xcodeproj::Plist.read_from_path(plist_path)
plist["ITSAppUsesNonExemptEncryption"] = false
plist["UISupportedInterfaceOrientations"] = ["UIInterfaceOrientationPortrait"]
plist["UISupportedInterfaceOrientations~ipad"] = %w[UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown
  UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight]
plist.delete("UIRequiredDeviceCapabilities") if plist["UIRequiredDeviceCapabilities"] == ["armv7"] # veraltet, Xcode setzt arm64
Xcodeproj::Plist.write_to_path(plist, plist_path)
puts "Info.plist: ITSAppUsesNonExemptEncryption = NO, iPhone Hochformat, iPad alle Richtungen"
