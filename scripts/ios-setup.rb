# Ergaenzt das frisch erzeugte iOS-Projekt (Capacitor 8, Swift Package Manager) um alles, was Saatzeit und der
# App Store verlangen. Der Ordner ios/ entsteht bei jedem Bau neu, darum stehen die Anpassungen hier:
#   1. Datenschutz-Manifest PrivacyInfo.xcprivacy nach ios/App/App kopieren und als Ressource der App eintragen
#   2. Info.plist: ITSAppUsesNonExemptEncryption = NO (Saatzeit nutzt keine eigene Verschluesselung,
#      sonst fragt App Store Connect bei jedem Build nach den Exportbestimmungen)
#   3. Nur iPhone (TARGETED_DEVICE_FAMILY = 1), kein iPad. Mindestversion iOS 15.
#   4. Versionsnummer der App (MARKETING_VERSION) aus package.json, z. B. 1.1.0. Passend dazu APP_VERSION in www/index.html.
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

# 3. Nur iPhone, iOS 15 / 4. Versionsnummer
MIN_IOS = "15.0"
version = JSON.parse(File.read(File.join(root, "package.json")))["version"]
(project.build_configurations + target.build_configurations).each do |config|
  config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = MIN_IOS
end
target.build_configurations.each do |config|
  config.build_settings["TARGETED_DEVICE_FAMILY"] = "1"
  config.build_settings["MARKETING_VERSION"] = version
end
# 6. Team (Personal Team), damit Xcode nach einem Neuaufbau von ios/ nicht nachfragt
team_file = File.join(root, "ios-team.txt")
team = File.file?(team_file) ? File.read(team_file).strip : ""
target.build_configurations.each { |c| c.build_settings["DEVELOPMENT_TEAM"] = team } unless team.empty?
# 5. Xcode 27: Anfuehrungszeichen-Includes in Framework-Headern nicht als Fehler werten
project.build_configurations.each { |c| c.build_settings["CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER"] = "NO" }
project.save
puts "PrivacyInfo.xcprivacy liegt in ios/App/App und ist im Projekt eingetragen."
puts "App-Projekt: nur iPhone, iOS #{MIN_IOS} als Mindestversion, Version #{version}"

# 2. Exportbestimmungen, iPad-Angaben entfernen
plist_path = File.join(app_dir, "Info.plist")
abort "Info.plist fehlt: #{plist_path}" unless File.file?(plist_path)
plist = Xcodeproj::Plist.read_from_path(plist_path)
plist["ITSAppUsesNonExemptEncryption"] = false
plist.delete("UISupportedInterfaceOrientations~ipad")
Xcodeproj::Plist.write_to_path(plist, plist_path)
puts "Info.plist: ITSAppUsesNonExemptEncryption = NO"
