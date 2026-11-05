# Saatzeit

Pflanzkalender für Kräuter, Gemüse, Beeren und Blumen rund ums Haus, als App für iPhone und Android.
Saatzeit zeigt, was du wann, wie und wo säen, pflanzen und ernten kannst, und führt dein eigenes Gartentagebuch.
Alle Daten bleiben auf dem Gerät. Es gibt kein Konto, keinen Server und kein Tracking.

## Funktionen

- **Leiste unten** mit vier Reitern: Heute, Kalender, Meine Pflanzen und Mehr (Einstellungen, Hilfe, Fragen & Antworten, Impressum).
- **Jetzt im …:** Die wichtigsten Arbeiten des Monats, der nächste Gartentermin (z. B. Eisheilige) und ein zufälliger Spruch aus 400 Einträgen: Bauernregeln zum Monat, saisonale Inspirationen für Konfitüre, Sirup, Tee und Deko sowie Gartensprüche. Die Farben der App wechseln mit der Jahreszeit.
- **74 Pflanzen**, eingeteilt in Kräuter, Gemüse, Früchte und Blumen, jeweils mit:
  - Zeitfenstern zum Vorziehen, Säen, Auspflanzen und Ernten
  - Saattiefe, Abstand, Keimdauer und Boden
  - Standort: Sonne oder Halbschatten, Beet, Topf oder Balkonkasten
  - Pflegetipps sowie guten und schlechten Nachbarn
- **Zwei Ansichten:** Jahresbalken für den Überblick oder Karten im Stil von Samentütchen.
- **Lage-Einstellung:** Mild, Mittelland, Voralpen und Höhenlage. Pro Stufe verschieben sich die Termine um etwa zwei Wochen.
- **Meine Pflanzen:** Du trägst ein, was du gesät oder gepflanzt hast. Die Übersicht gruppiert deine Pflanzungen nach «Jetzt erntereif», «Wächst noch» und «Erntezeit vorbei», jeweils mit Fortschrittsbalken bis zur Ernte.
- **Erinnerungen** als lokale Mitteilungen, ohne Server:
  - Gartentermine am Vorabend
  - der Tag, an dem eine Pflanzung erntereif wird
  - eine Woche vor Ablauf der Zeit für markierte Pflanzen (★)
  - ein kurzer Überblick zu jedem Monatsanfang
- **Sichern und Wiederherstellen** als JSON-Datei über Dateien oder iCloud Drive.

Die Termine sind Richtwerte für die Schweiz und Mitteleuropa.

## Aufbau

| Pfad | Inhalt |
|---|---|
| `www/index.html` | die ganze App: Oberfläche, Pflanzendaten, Sprüche und Logik in einer Datei. Sie ist zugleich die Hauptdatei für die Web-App und die claude.ai-Version. |
| `www/icon.svg` | Icon für die Browser-Ansicht |
| `www/fonts/` | Schriften als `.woff2` mit Lizenztexten (Bricolage Grotesque, Atkinson Hyperlegible, IBM Plex Mono) |
| `resources/icon-only.png` | App-Icon, 1024 × 1024 px, ohne Transparenz und mit eckigen Ecken (iOS rundet selbst) |
| `resources/icon-foreground.png`, `icon-background.png` | Ebenen für das Android-Adaptive-Icon (Motiv im sicheren Kreis) |
| `resources/splash.png` | Startbild, 2732 × 2732 px |
| `ios-extras/PrivacyInfo.xcprivacy` | Datenschutz-Manifest für den App Store: kein Tracking, keine erhobenen Daten, Gründe für UserDefaults (CA92.1) und Dateizeiten (C617.1) |
| `scripts/ios-setup.rb` | ergänzt das iOS-Projekt beim Bau: trägt das Manifest als Ressource ein und setzt in der `Info.plist` `ITSAppUsesNonExemptEncryption` auf NO (keine eigene Verschlüsselung, keine Exportfrage bei jedem Build) |
| `capacitor.config.json` | App-ID (`ch.saatzeit.app`), App-Name und Einstellungen |
| `package.json` | Capacitor und Plugins (Mitteilungen, Speicher, Dateien, Teilen) |
| `codemagic.yaml` | Cloud-Build auf Codemagic: unsignierte `.ipa` fürs iPhone und Test-APK für Android |
| `ANLEITUNG-IPHONE.md` | Schritt für Schritt: vom Repository bis zur App auf dem iPhone |
| `ANLEITUNG-ANDROID.md` | Schritt für Schritt: vom Repository bis zur App auf dem Android-Handy |

Die nativen Projekte (`ios/`, `android/`) liegen nicht im Repository. Sie werden bei jedem Build neu erzeugt.

## Technik

- Reines HTML, CSS und JavaScript, ohne Framework und ohne Build-Schritt für die Oberfläche.
- [Capacitor 8](https://capacitorjs.com) verpackt die Oberfläche als App für iPhone und Android. Verwendete Plugins:
  - `@capacitor/preferences`: dauerhafter Speicher für Einträge, Favoriten und Einstellungen
  - `@capacitor/local-notifications`: Erinnerungen
  - `@capacitor/filesystem` und `@capacitor/share`: Sicherungsdatei schreiben und teilen
- Im Browser läuft dieselbe Datei ohne die nativen Funktionen. Gespeichert wird dann im `localStorage`.

## Bauen

### In der Cloud (ohne Mac)

1. Das Repository mit [Codemagic](https://codemagic.io) verbinden.
2. Den Workflow **Saatzeit iPhone-Test (unsigniert)** starten.
3. Die Datei `Saatzeit-unsigniert.ipa` aus den Artifacts herunterladen.
4. Sie mit [Sideloadly](https://sideloadly.io) und einer Apple-ID aufs iPhone spielen.

Die genauen Schritte stehen in [ANLEITUNG-IPHONE.md](ANLEITUNG-IPHONE.md).

### Auf einem Mac

Voraussetzungen: Node.js 22, Xcode und CocoaPods (nur für das Ruby-Gem `xcodeproj`, Capacitor 8 baut mit Swift Package Manager).

```bash
npm install
npm run ios:prepare
npx cap open ios
```

Danach in Xcode ein Team zum Signieren wählen und die App auf dem iPhone starten.

### Nur die Oberfläche ansehen

Die Datei `www/index.html` über einen beliebigen lokalen Webserver öffnen. Erinnerungen und das Teilen-Menü gibt es dort nicht, alles andere funktioniert.

## Daten und Datenschutz

- Alle Einträge, Favoriten und Einstellungen bleiben auf dem Gerät.
- Die App sendet keine Daten an einen Server und lädt nichts nach. Schriften (`www/fonts/`, SIL Open Font License) und Icons sind in der App enthalten, sie funktioniert komplett offline.
- Eine Sicherung entsteht nur, wenn du selbst auf **Sichern** tippst.
