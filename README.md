# Claude Code Home Assistant Add-on

Ein Home Assistant Add-on, das eine Claude Code Entwicklungsumgebung mit `vibe-kanban` als Web-Interface bereitstellt.

## Features

- 🤖 **Claude Code** - CLI-Tool für KI-gestützte Entwicklung
- 📋 **Vibe Kanban** - Kanban-Board auf Port 3000
- 🔧 **Vollständige Dev-Umgebung** - Node.js 24, Git, GitHub CLI, SSH
- 💾 **Persistente Daten** - Alle Konfigurationen und Projekte bleiben erhalten

## Lokales Testing mit Docker

### Voraussetzungen

- Docker Desktop installiert und läuft

### Schnellstart

1. **Container bauen und starten:**
   ```bash
   docker-compose up --build
   ```

2. **Web-Interface öffnen:**
   ```
   http://localhost:3000
   ```

3. **Container stoppen:**
   ```bash
   docker-compose down
   ```

### Git-Konfiguration anpassen

Bearbeiten Sie [test/options.json](test/options.json):
```json
{
  "git_user_name": "Ihr Name",
  "git_user_email": "ihre@email.com"
}
```

Dann Container neu starten:
```bash
docker-compose restart
```

### SSH-Keys für Git-Operationen

1. SSH-Keys in `test-data/ssh/` ablegen:
   ```
   test-data/
   └── ssh/
       ├── id_ed25519          # Private key
       ├── id_ed25519.pub      # Public key
       ├── known_hosts         # Optional
       └── config              # Optional
   ```

2. Container neu starten - die Berechtigungen werden automatisch gesetzt

### Persistente Daten

Alle Daten werden in `test-data/` gespeichert:
- `workspace/` - Ihre Projekte
- `ssh/` - SSH-Konfiguration
- `claude-config/` - Claude Code Einstellungen
- `vibe-kanban/` - Kanban-Board Daten
- `gh-config/` - GitHub CLI Konfiguration
- `git-config/` - Git globale Konfiguration

### Entwicklung

Nach Änderungen an `dockerfile` oder `run.sh`:
```bash
docker-compose up --build
```

### Logs ansehen

```bash
docker-compose logs -f
```

### Container Shell öffnen

```bash
docker exec -it hassio-claude-code-test bash
```

## Installation in Home Assistant

### Voraussetzung: Repository auf GitHub veröffentlichen

1. **Repository.yaml anpassen:**
   - Bearbeiten Sie [repository.yaml](repository.yaml)
   - Tragen Sie Ihre GitHub-URL und Daten ein

2. **Code zu GitHub pushen:**
   ```bash
   git add .
   git commit -m "Add Home Assistant add-on"
   git push
   ```

### In Home Assistant installieren

1. **Repository hinzufügen:**
   - Supervisor → Add-on Store → ⋮ (Menü oben rechts) → Repositories
   - Ihre GitHub-URL eingeben: `https://github.com/YOURUSERNAME/hassio-addons-claude`
   - "Add" klicken

2. **Add-on installieren:**
   - Scrollen Sie nach unten zu Ihren eigenen Repositories
   - "Claude Code" wählen
   - "Install" klicken

3. **Konfigurieren:**
   - Tab "Configuration" öffnen
   - Git User Name und Email eingeben:
     ```yaml
     git_user_name: Ihr Name
     git_user_email: ihre@email.com
     ```
   - "Save" klicken

4. **Starten:**
   - Tab "Info" öffnen
   - "Start" klicken
   - Optional: "Start on boot" aktivieren

5. **Zugriff:**
   - `http://homeassistant.local:3000`
   - Oder über "Open Web UI" Button im Add-on

## Architektur

Siehe [CLAUDE.md](CLAUDE.md) für detaillierte Informationen über:
- Container-Struktur
- Persistente Datenspeicherung
- Startup-Prozess
- Konfiguration

## Lizenz

MIT
