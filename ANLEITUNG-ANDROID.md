# Saatzeit aufs Android-Handy (z. B. Oppo Reno 2)

Codemagic baut aus demselben Projekt eine Android-App (`Saatzeit-test.apk`). Du installierst sie direkt auf dem Handy.
Dafür brauchst du kein Zusatzkonto und kein Android Studio. Die App läuft dauerhaft, es gibt keine 7-Tage-Grenze.

---

## 1. Änderungen auf GitHub bringen

Der Ordner `saatzeit-ios` auf dem Mac ist mit GitHub verbunden. In **GitHub Desktop** erscheinen alle Änderungen
von selbst. Unten links eine kurze Beschreibung eintragen, auf **Commit to main** und danach oben auf **Push origin** klicken.

## 2. APK bauen lassen

1. In Codemagic die App **Saatzteit-ios** öffnen und auf **Start new build** klicken.
2. Als Workflow **Saatzeit Android-Test (APK)** wählen, als Branch **main**.
3. Nach etwa 10 Minuten unter **Artifacts** die Datei **`Saatzeit-test.apk`** herunterladen.

Wird ein Schritt rot, kopiere den roten Text in den Chat.

## 3. Oppo vorbereiten

1. **Browser-Motor aktualisieren:** Im Play Store nach **Android System WebView** und **Chrome** suchen und beide aktualisieren.
   Saatzeit läuft im eingebauten Browser-Motor. Mit einer alten Version stimmen einige Farben nicht.
2. **APK aufs Handy bringen,** zum Beispiel:
   - per Mail an dich selbst und auf dem Handy öffnen
   - in Google Drive oder OneDrive legen
   - per USB-Kabel in den Ordner «Download» kopieren

## 4. Installieren

1. Die Datei `Saatzeit-test.apk` auf dem Handy antippen, zum Beispiel in der App **Dateimanager** unter «Download».
2. ColorOS fragt, ob die App (Dateimanager, Gmail oder Drive) **unbekannte Apps installieren** darf. Tippe auf
   **Einstellungen** und erlaube es, dann zurück.
3. Auf **Installieren** tippen. Eventuell fragt ColorOS nach einer Sicherheitsprüfung, dann bestätigst du sie.
4. Saatzeit erscheint auf dem Startbildschirm.

## 5. Erinnerungen zuverlässig machen

ColorOS beendet Apps im Hintergrund sehr streng. Damit die Erinnerungen kommen:

1. In Saatzeit unter **Mehr → Einstellungen → Mitteilungen** die Erinnerungen einschalten und Benachrichtigungen erlauben.
2. **Einstellungen → Akku → App-Akkuverwaltung → Saatzeit** öffnen und **Hintergrundaktivität erlauben** einschalten.
   Je nach ColorOS-Version heisst das auch «Im Hintergrund ausführen» oder «Autostart erlauben».
3. Falls vorhanden: **Einstellungen → App-Verwaltung → Saatzeit → Benachrichtigungen** auf erlaubt stellen.

## Updates

Neue Version bauen (Schritt 2), die neue APK herunterladen und wie in Schritt 4 installieren. Sie ersetzt die alte App,
deine Einträge bleiben erhalten.

## Gut zu wissen

- Die Test-APK ist mit einem Testschlüssel signiert. Für Google Play bräuchte es später einen eigenen Schlüssel
  und ein Google-Play-Entwicklerkonto (einmalig rund 25 USD).
- Mit der Zurück-Taste von Android wechselst du zwischen den Seiten, die du im Menü geöffnet hast.
