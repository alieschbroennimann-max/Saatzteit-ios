# Saatzeit als Test-App aufs iPhone (mit dem MacBook)

Es gibt zwei Wege. Bei beiden läuft die App mit einer kostenlosen Apple-ID jeweils **7 Tage** und lässt sich danach
erneut aufspielen. Deine Einträge bleiben dabei erhalten.

| | Weg A: direkt mit Xcode | Weg B: Codemagic und Sideloadly |
|---|---|---|
| Gebaut wird | auf deinem MacBook | in der Cloud |
| Braucht | Xcode (etwa 40 GB freier Platz), CocoaPods | GitHub, Codemagic, Sideloadly |
| Gut, wenn | genug Platz frei ist, du oft testest | wenig Platz frei ist |

Für beide Wege einmal am iPhone: **Entwicklermodus einschalten** (Einstellungen → Datenschutz & Sicherheit →
**Entwicklermodus** → ein). Das iPhone startet neu, danach die Nachfrage mit **Einschalten** bestätigen.
Der Schalter erscheint eventuell erst, nachdem das iPhone einmal mit Xcode oder Sideloadly verbunden war.

---

## Weg A: direkt mit Xcode

### Einmalig einrichten

1. **Platz schaffen:** Xcode braucht etwa 40 GB. Freien Platz zeigt  → Systemeinstellungen → Allgemein → Speicher.
2. **Xcode** aus dem **Mac App Store** installieren. Einmal öffnen, die Lizenz bestätigen und, wenn Xcode danach
   fragt, die Komponente **iOS** herunterladen.
3. **Node.js** (LTS) von [nodejs.org](https://nodejs.org) installieren, falls noch nicht geschehen.
4. **Homebrew** installieren: Den Befehl von [brew.sh](https://brew.sh) im Terminal ausführen.
5. **CocoaPods** installieren, im Terminal:

   ```
   brew install cocoapods
   ```

6. **Apple-ID in Xcode:** Xcode → Einstellungen → **Accounts** → **+** → Apple-ID anmelden.

### Das erste Mal bauen

Terminal öffnen, in den Ordner `saatzeit-ios` wechseln und ausführen:

```
cd ~/Documents/Saatzeit/saatzeit-ios
npm install
npm run ios:prepare
npx cap open ios
```

`npm run ios:prepare` erzeugt den Ordner `ios/` mit dem Xcode-Projekt und die Icons, trägt das Datenschutz-Manifest
ein und setzt iOS 15 als Mindestversion (Xcode 27 baut nicht mehr für iOS 14). Das dauert ein bis zwei Minuten.

### In Xcode

1. Links ganz oben auf **App** klicken, dann in der Mitte das Ziel **App** und den Reiter **Signing & Capabilities**.
2. Bei **Team** dein **Personal Team** (deinen Namen) wählen.
   Meldet Xcode, die Bundle-ID sei schon vergeben, bei **Bundle Identifier** eine eigene wählen, zum Beispiel
   `ch.saatzeit.test.deinname`.
3. iPhone per Kabel anschliessen, entsperren und **«Diesem Computer vertrauen»** bestätigen.
4. Oben in der Leiste dein iPhone als Ziel wählen und auf **▶** (Run) klicken.
5. Beim ersten Mal auf dem iPhone: Einstellungen → Allgemein → **VPN & Geräteverwaltung** → deine Apple-ID →
   **Vertrauen**. Dann in Xcode nochmals ▶.

### Nach einer Änderung an Saatzeit

```
cd ~/Documents/Saatzeit/saatzeit-ios
npm run ios:update
npx cap open ios
```

Dann in Xcode ▶. Bietet Xcode «Update to recommended settings» an, kannst du das annehmen: `npm run ios:update`
stellt danach wieder ein, was Saatzeit braucht. `npm run ios:prepare` läuft nur beim ersten Mal, solange der Ordner `ios/` noch nicht existiert.
Für einen ganz frischen Bau den Ordner `ios/` löschen und wieder mit `npm run ios:prepare` beginnen.

### Nach 7 Tagen

Die App startet nicht mehr. iPhone anschliessen, Xcode öffnen und ▶ klicken. Die Einträge bleiben erhalten.

---

## Weg B: Codemagic und Sideloadly

### 1. Änderungen auf GitHub bringen

Der Ordner `saatzeit-ios` auf dem Mac ist mit GitHub verbunden. In **GitHub Desktop** erscheinen alle Änderungen
von selbst. Unten links eine kurze Beschreibung eintragen, auf **Commit to main** und danach oben auf **Push origin** klicken.

### 2. App bauen lassen

1. In [Codemagic](https://codemagic.io) die App **Saatzteit-ios** öffnen und auf **Start new build** klicken.
2. Den Workflow **Saatzeit iPhone-Test (unsigniert)** und den Branch **main** wählen.
3. Nach 10 bis 15 Minuten unter **Artifacts** die Datei `Saatzeit-unsigniert.ipa` herunterladen.

Wird ein Schritt rot, kopiere den roten Teil des Protokolls in den Chat.

### 3. Mit Sideloadly aufs iPhone

1. Sideloadly **für macOS** von der offiziellen Seite [sideloadly.io](https://sideloadly.io) installieren und
   die Hinweise dort für den Mac befolgen. iTunes braucht es auf dem Mac nicht.
2. iPhone per Kabel anschliessen und **«Diesem Computer vertrauen»** bestätigen.
3. Die `.ipa` ins Sideloadly-Fenster ziehen, deine Apple-ID eintragen und auf **Start** klicken.
   Sideloadly leitet die Anmeldung nur an Apple weiter. Wer vorsichtig sein möchte, nimmt für Tests eine zweite,
   kostenlose Apple-ID.
4. Beim ersten Mal auf dem iPhone: Einstellungen → Allgemein → **VPN & Geräteverwaltung** → deine Apple-ID →
   **Vertrauen**.

Nach 7 Tagen dieselbe `.ipa` nochmals mit Sideloadly aufspielen. Die Einträge bleiben erhalten.

---

## Erinnerungen einschalten

In Saatzeit im Menü **Meine Pflanzen** öffnen, zu **Erinnerungen** scrollen und auf **Erinnerungen: aus** tippen.
Saatzeit erklärt kurz, wozu, danach fragt das iPhone nach der Erlaubnis. Saatzeit erinnert dann an:

- wichtige Gartentermine, jeweils am Vorabend um 18 Uhr (zum Beispiel die Eisheiligen)
- den Tag, an dem deine eingetragenen Pflanzungen erntereif werden, um 8 Uhr
- markierte Pflanzen (★), eine Woche bevor die Zeit zum Säen oder Pflanzen abläuft
- den Beginn der Saatzeit einer Pflanze, um 9 Uhr: Auf der Seite der Pflanze unter **Wann** auf
  **Erinnere mich, wenn es losgeht** tippen. Sind die Erinnerungen noch aus, schaltet der Knopf sie gleich ein.
- jeden Monatsanfang mit einem kurzen Überblick

## Gut zu wissen

- Mit einer kostenlosen Apple-ID kannst du höchstens 3 solcher Apps gleichzeitig installiert haben.
- **Sichere ab und zu:** Unter **Meine Pflanzen → Sichern** legst du eine Kopie in Dateien oder iCloud Drive ab.
  Mit **Wiederherstellen** holst du sie zurück, zum Beispiel nach einem Handywechsel.
- Mit dem bezahlten Apple-Entwicklerkonto (99 USD pro Jahr) fällt die 7-Tage-Grenze weg. Dann kommt die App über
  TestFlight aufs iPhone.
