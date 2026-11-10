# RomM for Home Assistant (unofficial)

A Home Assistant app (formerly "add-on") that wraps the official
[RomM](https://github.com/rommapp/romm) image, so you can run your ROM manager
directly on Home Assistant OS.

> ## ⚠️ Read this first
> **This was put together quickly with the help of AI and has not been properly tested. It probably won't work yet.**
> Expect build errors, startup failures and rough edges. It is shared as a starting point, not a finished product.
> Don't point it at anything you can't afford to lose, and please don't expect it to behave like a polished release.
>
> This project is **not affiliated with or endorsed by the RomM project or Home Assistant**.
> Problems with this wrapper belong in [this repo's issues](https://github.com/WCRalph/HA-RomM/issues),
> not in RomM's support channels.

## Requirements

- Home Assistant OS (or another install type that supports apps)
- The official **MariaDB** app, installed and started
- A reasonably capable host: RomM's metadata scans are heavy and will compete with Home Assistant itself on a small board like a Raspberry Pi

## Installation

1. In Home Assistant go to **Settings → Apps → Store → ⋮ → Repositories** and add:

   ```
   https://github.com/WCRalph/HA-RomM
   ```

2. Install and start the **MariaDB** app.
3. Install **RomM** from this repository. The first install builds the image on your device, which can take a while.
4. Start it and open the web UI at `http://<your-ha-ip>:7666`, then create your admin user.

The app creates its `romm` database automatically. If that fails, add `romm` to the MariaDB app's `databases` option and restart MariaDB.

## Where things live

| What | Where |
|---|---|
| ROM library | `/media/romm/library/roms/<platform>/` (e.g. `roms/snes/`) |
| `config.yml` | `/addon_configs/<slug>_romm/config.yml` |
| Covers, screenshots, saves | The app's `/data` (included in app backups, so backups can get large) |

Metadata provider keys (IGDB, ScreenScraper, SteamGridDB, RetroAchievements, MobyGames) are set on the app's **Configuration** tab. Leave `auth_secret_key` empty to have one generated and kept for you.

## Known limitations

- Untested. See the warning above.
- Home Assistant ingress (sidebar panel) is **experimental**. RomM isn't designed to run under a URL subpath, so the panel may be blank or partly broken. The direct port (7666) always works.
- Redis runs inside the container and its cache isn't kept across restarts.
- The Dockerfile uses RomM's `latest` tag. Pin a specific version (the `ROMM_VERSION` build arg) once you have a working setup, since RomM has had breaking changes between major versions.
- Because the library is symlinked in from `/media`, upstream features that rely on hardlinks across mounts may not work.

## Credits

All the real work is done by [RomM](https://github.com/rommapp/romm). This repo only packages its official image for Home Assistant.

## License

[MIT](LICENSE) for the files in this repository. RomM itself is licensed separately by its authors.
