// Ergaenzt das frisch erzeugte Android-Projekt (der Ordner android/ entsteht bei jedem Bau neu):
//   Versionsnummer (versionName) und Build-Nummer (versionCode) aus package.json ("version" und "build"),
//   passend zu APP_VERSION in www/index.html. Der Play Store verlangt wie Apple bei jedem Upload einen hoeheren versionCode.
// Aufruf nach "npx cap add android" im Ordner saatzeit-ios:  node scripts/android-setup.mjs
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const { version, build } = JSON.parse(readFileSync(join(root, "package.json"), "utf8"));
if (!(Number(build) >= 1)) throw new Error('package.json: "build" fehlt oder ist kleiner als 1.');
const gradle = join(root, "android", "app", "build.gradle");
const text = readFileSync(gradle, "utf8");
if (!/versionName\s+"[^"]*"/.test(text)) throw new Error("versionName fehlt in android/app/build.gradle.");
if (!/versionCode\s+\d+/.test(text)) throw new Error("versionCode fehlt in android/app/build.gradle.");
writeFileSync(gradle, text.replace(/versionName\s+"[^"]*"/, `versionName "${version}"`).replace(/versionCode\s+\d+/, `versionCode ${Number(build)}`));
console.log(`build.gradle: versionName ${version}, versionCode ${Number(build)}`);
