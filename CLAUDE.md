# Saatzeit iOS – Hinweise für Claude

Dieser Ordner ist der iPhone-Teil von Saatzeit (Capacitor 8) und entspricht dem GitHub-Repo
`alieschbroennimann-max/Saatzteit-ios`. Das ganze Projekt liegt im übergeordneten Ordner `Saatzeit`.
Dort steht in der `CLAUDE.md` alles zu Aufbau und Arbeitsweise.

Kurz:
- `www/index.html` ist die **einzige Hauptdatei** für alle Versionen (iPhone, Web-App, claude.ai). Nur hier ändern.
- Nach Änderungen im übergeordneten Ordner `node build.mjs` ausführen und die claude.ai-Version neu veröffentlichen.
- `www/capacitor.js` wird beim Bau aus `node_modules/@capacitor/core/dist/capacitor.js` kopiert, nicht einchecken.
- Sprache: Deutsch (Schweiz, «ss» statt «ß»). Zuerst im Browser testen, die iPhone-App nur auf Wunsch neu bauen.
