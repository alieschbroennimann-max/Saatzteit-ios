# Saatzeit als Test-App aufs iPhone

So kommt Saatzeit als echte App auf dein iPhone, gratis und ohne Mac. Die App läuft jeweils **7 Tage** und lässt sich danach mit einem Klick verlängern.

Der Ablauf:

1. **GitHub** speichert den Code.
2. **Codemagic** baut daraus in der Cloud die App, als Datei `Saatzeit-unsigniert.ipa`.
3. **Sideloadly** unterschreibt die Datei mit deiner Apple-ID und spielt sie aufs iPhone.

Für den ersten Durchgang solltest du etwa eine Stunde einplanen.

---

## 1. Code auf GitHub hochladen

1. Auf [github.com](https://github.com) ein kostenloses Konto erstellen.
2. Oben rechts auf **+** → **New repository**.
   - Name: `saatzeit`
   - **Private** wählen
   - Auf **Create repository** klicken.
3. Auf der nächsten Seite auf den Link **uploading an existing file** klicken.
4. Den **Inhalt** des Ordners `saatzeit-ios` in das Feld ziehen, also nicht den Ordner selbst. Hochgeladen werden müssen:
   - `www` (Ordner)
   - `resources` (Ordner)
   - `package.json`
   - `capacitor.config.json`
   - `codemagic.yaml`
   - `.gitignore`

   Die Datei `.gitignore` ist im Windows-Explorer eventuell versteckt. Ohne sie geht es auch.
5. Unten auf **Commit changes** klicken.

## 2. App bauen lassen mit Codemagic

1. Auf [codemagic.io](https://codemagic.io) gehen und **mit GitHub anmelden**. Den Zugriff auf das Repository `saatzeit` erlauben.
2. **Add application** → GitHub → Repository `saatzeit` auswählen.
   - Falls nach dem Projekttyp gefragt wird: **Capacitor**, oder «Other», wenn es keine passende Auswahl gibt.
3. Codemagic findet die Datei `codemagic.yaml` von selbst.
4. Auf **Start new build** klicken und den Workflow **Saatzeit iPhone-Test (unsigniert)** wählen.
5. Der Bau dauert etwa 10 bis 15 Minuten. Danach unter **Artifacts** die Datei `Saatzeit-unsigniert.ipa` herunterladen.

Schlägt der Bau fehl, kopiere mir den roten Teil des Protokolls. Dann schaue ich es mir an.

## 3. Sideloadly auf dem PC einrichten

1. Sideloadly von der offiziellen Seite [sideloadly.io](https://sideloadly.io) herunterladen und installieren.
2. Sideloadly braucht **iTunes** und **iCloud für Windows**, und zwar die Versionen **direkt von apple.com**, nicht aus dem Microsoft Store. Die genauen Links stehen auf der Sideloadly-Seite.
3. Das iPhone per USB-Kabel anschliessen und auf dem iPhone **«Diesem Computer vertrauen»** bestätigen.

## 4. App aufs iPhone spielen

1. Sideloadly öffnen. Das iPhone sollte oben erscheinen.
2. Die Datei `Saatzeit-unsigniert.ipa` in das Sideloadly-Fenster ziehen.
3. Deine **Apple-ID** (E-Mail) eintragen und auf **Start** klicken. Sideloadly fragt nach deinem Apple-Passwort und eventuell nach einem Bestätigungscode.
   - Sideloadly leitet die Anmeldung nur an Apple weiter. Wer vorsichtig sein möchte, legt für Tests eine zweite, kostenlose Apple-ID an.
4. Nach etwa einer Minute meldet Sideloadly **Done**.

## 5. Auf dem iPhone freigeben

1. **Entwicklermodus einschalten** (ab iOS 16): Einstellungen → Datenschutz & Sicherheit → **Entwicklermodus** → ein. Das iPhone startet neu. Danach die Nachfrage mit **Einschalten** bestätigen.
2. **Der eigenen App vertrauen:** Einstellungen → Allgemein → **VPN & Geräteverwaltung** → deine Apple-ID antippen → **Vertrauen**.
3. Saatzeit auf dem Home-Bildschirm öffnen. 🌱

## 6. Erinnerungen einschalten

Oben in der App auf **Erinnerungen: aus** tippen und die Mitteilungen erlauben. Saatzeit erinnert dich dann an:

- wichtige Gartentermine, jeweils am Vorabend um 18 Uhr (zum Beispiel die Eisheiligen)
- den Tag, an dem deine eingetragenen Pflanzungen erntereif werden, um 8 Uhr
- markierte Pflanzen (★), eine Woche bevor die Zeit zum Säen oder Pflanzen abläuft
- jeden Monatsanfang mit einem kurzen Überblick

## Nach 7 Tagen

Die App startet dann nicht mehr. Deine Daten bleiben aber erhalten.

- Sideloadly erneut öffnen, dieselbe `.ipa` hineinziehen und auf **Start** klicken. Die App wird über die alte installiert, deine Einträge bleiben.
- In Sideloadly lässt sich auch eine automatische Verlängerung einschalten, wenn PC und iPhone im selben WLAN sind.

## Gut zu wissen

- Mit einer kostenlosen Apple-ID kannst du höchstens 3 solcher Apps gleichzeitig installiert haben.
- **Sichere ab und zu:** Mit **Sichern** in «Mein Garten» legst du eine Kopie in Dateien oder iCloud Drive ab. Mit **Wiederherstellen** holst du sie zurück, zum Beispiel nach einem Handywechsel.
- Ändert sich Saatzeit, lädst du die geänderten Dateien auf GitHub hoch, startest in Codemagic einen neuen Build und spielst die neue `.ipa` mit Sideloadly auf.
