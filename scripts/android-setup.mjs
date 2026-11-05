// Ergaenzt das frisch erzeugte Android-Projekt (der Ordner android/ entsteht bei jedem Bau neu):
//   Versionsnummer der App (versionName) aus package.json, passend zu APP_VERSION in www/index.html.
// Aufruf nach "npx cap add android" im Ordner saatzeit-ios:  node scripts/android-setup.mjs
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const { version } = JSON.parse(readFileSync(join(root, "package.json"), "utf8"));
const gradle = join(root, "android", "app", "build.gradle");
const text = readFileSync(gradle, "utf8");
if (!/versionName\s+"[^"]*"/.test(text)) throw new Error("versionName fehlt in android/app/build.gradle.");
writeFileSync(gradle, text.replace(/versionName\s+"[^"]*"/, `versionName "${version}"`));
console.log(`build.gradle: versionName ${version}`);
