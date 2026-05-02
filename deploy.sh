#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="${HERMES_DATA_DIR:-$SCRIPT_DIR/data}"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

# Compose shim: prefer v2 plugin, fall back to standalone v1
compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  else
    docker-compose "$@"
  fi
}

# ── First-run: initialize data directory ────────────────────────────────────
if [ ! -f "$DATA_DIR/config.yaml" ]; then
  echo "==> Initializing data directory: $DATA_DIR"
  mkdir -p "$DATA_DIR"
  cp "$SCRIPT_DIR/config.yaml" "$DATA_DIR/config.yaml"
  echo "    config.yaml copied."
  echo "    Run 'docker exec -it hermes-agent hermes auth' after startup to set up credentials."
fi

# ── Build ────────────────────────────────────────────────────────────────────
echo "==> Building image"
compose -f "$COMPOSE_FILE" build

# ── Start (or restart) ───────────────────────────────────────────────────────
echo "==> Starting container"
compose -f "$COMPOSE_FILE" up -d --force-recreate

# ── Verify ───────────────────────────────────────────────────────────────────
echo "==> Verifying"
docker exec hermes-agent rtk --version
echo "Done. Gateway listening on 127.0.0.1:8642"
