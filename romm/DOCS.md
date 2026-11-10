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
| ROM library | `library_path` option (default `/media/romm/library`) |
| config.yml | `/addon_configs/<slug>_romm/config.yml` |
| Covers / screenshots | `resources_path` option (default `/data/resources`) |
| Saves / states | `assets_path` option (default `/data/assets`) |

## Notes
- Leave `auth_secret_key` empty to auto-generate one (persisted in `/data`).
- Redis runs inside the container; its cache is not persisted across restarts.

## Using a network share
Mount it in HA first (Settings > System > Storage > Add network storage) with usage **Media** (appears at `/media/<name>`) or **Share** (appears at `/share/<name>`).
Then set `library_path` in this app's Configuration to that folder, e.g. `/media/retro`, and restart.
RomM expects ROMs at `<library_path>/roms/<platform>/` (or `<library_path>/<platform>/roms/`).

## Path options
All of these are in the app's Configuration tab. Restart the app after changing them.

| Option | Default | Allowed locations |
|---|---|---|
| `library_path` | `/media/romm/library` | `/media/...` or `/share/...` (must already exist unless default) |
| `resources_path` | `/data/resources` | `/data/`, `/media/`, `/share/`, `/config/` |
| `assets_path` | `/data/assets` | `/data/`, `/media/`, `/share/`, `/config/` |

Anything under `/data` is included in app backups; put large resources on a share to keep backups small.

## Ingress (experimental)
The app adds a RomM entry to the HA sidebar via ingress. RomM isn't built for URL subpaths, so this may not render properly. If it doesn't, use `http://<ha-ip>:7666` directly. RomM has its own login; ingress does not sign you in automatically.
