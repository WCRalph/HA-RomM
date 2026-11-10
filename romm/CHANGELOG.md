# Changelog

## 0.1.2

- EXPERIMENTAL: enabled Home Assistant ingress (sidebar panel). May not render correctly. The direct port (7666) still works.

## 0.1.1

- Added `library_path` option so the ROM library can be a mounted network share (`/media/...` or `/share/...`).
- Added `resources_path` and `assets_path` options.
- Added `share` mapping.

## 0.1.0

- Initial experimental release. Untested, built quickly with AI assistance.
- Wraps the official `rommapp/romm` image.
- Uses the official MariaDB app and creates the database automatically.
