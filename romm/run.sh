#!/usr/bin/env bash
set -euo pipefail

OPTS=/data/options.json
log() { echo "[romm-app] $*"; }

# Read an option; prints nothing if unset/null/empty-string. Booleans print true/false.
opt() {
  jq -r --arg k "$1" \
    'if has($k) and .[$k] != null and .[$k] != "" then .[$k] | tostring else empty end' "$OPTS"
}

# Export ENV_NAME from option_name only if it has a value
export_opt() {
  local val; val="$(opt "$2")"
  if [ -n "$val" ]; then export "$1=$val"; fi
}

# Make $2 a symlink to persistent dir $1 (moving any existing content across)
link_dir() {
  local target="$1" link="$2"
  mkdir -p "$target"
  if [ -L "$link" ]; then ln -sfn "$target" "$link"; return; fi
  if [ -d "$link" ]; then
    cp -a "$link"/. "$target"/ 2>/dev/null || true
    rm -rf "$link"
  fi
  mkdir -p "$(dirname "$link")"
  ln -s "$target" "$link"
}

# ---- Database (official MariaDB app via Supervisor services API) ----
if ! SVC="$(curl -fsS -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" http://supervisor/services/mysql)"; then
  log "ERROR: could not read the mysql service. Install and start the MariaDB app first."
  exit 1
fi
export DB_HOST="$(jq -r '.data.host' <<<"$SVC")"
export DB_PORT="$(jq -r '.data.port' <<<"$SVC")"
export DB_USER="$(jq -r '.data.username' <<<"$SVC")"
export DB_PASSWD="$(jq -r '.data.password' <<<"$SVC")"
export DB_NAME="$(opt db_name)"
DB_NAME="${DB_NAME:-romm}"; export DB_NAME

# Only allow a safe identifier since it is interpolated into SQL
if ! [[ "$DB_NAME" =~ ^[A-Za-z0-9_]+$ ]]; then
  log "ERROR: db_name may only contain letters, digits and underscores."
  exit 1
fi

# Create the database if it doesn't exist (needs CREATE privilege for the service user)
export MYSQL_PWD="$DB_PASSWD"
if mariadb --skip-ssl -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" \
     -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"; then
  log "Database '${DB_NAME}' is ready on ${DB_HOST}:${DB_PORT}"
else
  log "WARNING: could not verify/create database '${DB_NAME}'. If RomM fails to connect, add it to the MariaDB app's 'databases' option."
fi
unset MYSQL_PWD

# ---- Auth secret key (generate once and persist if not set) ----
KEY="$(opt auth_secret_key)"
if [ -z "$KEY" ]; then
  [ -s /data/auth_secret_key ] || head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > /data/auth_secret_key
  KEY="$(cat /data/auth_secret_key)"
fi
export ROMM_AUTH_SECRET_KEY="$KEY"

# ---- Metadata providers ----
export_opt IGDB_CLIENT_ID igdb_client_id
export_opt IGDB_CLIENT_SECRET igdb_client_secret
export_opt SCREENSCRAPER_USER screenscraper_user
export_opt SCREENSCRAPER_PASSWORD screenscraper_password
export_opt STEAMGRIDDB_API_KEY steamgriddb_api_key
export_opt RETROACHIEVEMENTS_API_KEY retroachievements_api_key
export_opt MOBYGAMES_API_KEY mobygames_api_key
export_opt HASHEOUS_API_ENABLED hasheous_api_enabled
export_opt PLAYMATCH_API_ENABLED playmatch_api_enabled

# ---- Persistent storage layout ----
# /romm is a VOLUME in the upstream image, so subfolders can be symlinked.
LIB="$(opt library_path)"; LIB="${LIB:-/media/romm/library}"; LIB="${LIB%/}"
case "$LIB" in
  /media/*|/share/*) ;;
  *) log "ERROR: library_path must start with /media/ or /share/ (got '$LIB')"; exit 1 ;;
esac
if [ "$LIB" = "/media/romm/library" ]; then
  mkdir -p "$LIB/roms"                         # default location: create it for the user
elif [ ! -d "$LIB" ]; then
  log "ERROR: library_path '$LIB' does not exist. Check the network share is mounted and the path is right."
  log "Folders visible under /media: $(ls -1 /media 2>/dev/null | tr '\n' ' ')"
  log "Folders visible under /share: $(ls -1 /share 2>/dev/null | tr '\n' ' ')"
  exit 1
fi
log "ROM library: $LIB"
link_dir "$LIB" /romm/library                  # RomM expects <library>/roms/<platform>/
link_dir /config            /romm/config       # config.yml: /addon_configs/<slug>_romm/

# Validate an optional path setting: must live under a mapped location
resolve_path() {  # $1=option name, $2=default
  local v; v="$(opt "$1")"; v="${v:-$2}"; v="${v%/}"
  case "$v" in
    /media/*|/share/*|/data/*|/config/*) echo "$v" ;;
    *) log "ERROR: $1 must start with /media/, /share/, /data/ or /config/ (got '$v')"; exit 1 ;;
  esac
}
RES="$(resolve_path resources_path /data/resources)"
AST="$(resolve_path assets_path /data/assets)"
log "Resources (covers/screenshots): $RES"
log "Assets (saves/states): $AST"
link_dir "$RES" /romm/resources
link_dir "$AST" /romm/assets

log "Starting RomM"
exec /docker-entrypoint.sh /init
