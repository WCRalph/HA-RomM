# RomM

Wraps the official `rommapp/romm` image.

> **Warning:** unofficial and experimental. This was made quickly with AI assistance, has not been properly tested, and probably won't work yet.

## Setup
1. Install and start the **MariaDB** app. This app creates the `romm` database automatically on start (if that ever fails, add `romm` to MariaDB's `databases` option and restart it).
2. Install and start this app. Open the web UI at `http://<ha-host>:7666` and create your admin user.
3. Put ROMs in `/media/romm/library/roms/<platform>/` (e.g. `roms/snes/`), then run a scan from the UI.
4. Optional: add metadata keys (IGDB, ScreenScraper, etc.) in the app Configuration tab.

## Paths
| What | Where |
|---|---|
| ROM library | `/media/romm/library` |
| config.yml | `/addon_configs/<slug>_romm/config.yml` |
| Covers / screenshots / saves | app `/data` (included in app backups) |

## Notes
- Leave `auth_secret_key` empty to auto-generate one (persisted in `/data`).
- Redis runs inside the container; its cache is not persisted across restarts.
