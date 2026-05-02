#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

# ── Resolve data directory ───────────────────────────────────────────────────
# Priority: HERMES_DATA_DIR env var > running container's current mount > ./data
if [ -n "$HERMES_DATA_DIR" ]; then
  DATA_DIR="$HERMES_DATA_DIR"
else
  # Preserve the data dir of an already-running container so we never silently
  # switch to ./data and lose Telegram/auth/session state.
  RUNNING_MOUNT=$(docker inspect hermes-agent 2>/dev/null \
    | python3 -c "import json,sys; m=[b['Source'] for b in json.load(sys.stdin)[0]['Mounts'] if b['Destination']=='/opt/data']; print(m[0] if m else '')" 2>/dev/null || true)
  if [ -n "$RUNNING_MOUNT" ]; then
    DATA_DIR="$RUNNING_MOUNT"
    echo "==> Using existing data dir: $DATA_DIR"
  else
    DATA_DIR="$SCRIPT_DIR/data"
  fi
fi
export HERMES_DATA_DIR="$DATA_DIR"

# ── Compose shim: prefer v2 plugin, fall back to standalone v1 ───────────────
compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  else
    docker-compose "$@"
  fi
}

# ── First-run: seed config into a brand-new data directory ──────────────────
if [ ! -f "$DATA_DIR/config.yaml" ]; then
  echo "==> First run — initializing data directory: $DATA_DIR"
  mkdir -p "$DATA_DIR"
  cp "$SCRIPT_DIR/config.yaml" "$DATA_DIR/config.yaml"
  echo "    config.yaml copied."
  echo "    After startup, run: docker exec -it hermes-agent hermes auth"
fi

# ── Build ────────────────────────────────────────────────────────────────────
echo "==> Building image"
compose -f "$COMPOSE_FILE" build

# ── Start (or restart) ───────────────────────────────────────────────────────
echo "==> Starting container (data: $DATA_DIR)"
compose -f "$COMPOSE_FILE" up -d --force-recreate

# ── Verify ───────────────────────────────────────────────────────────────────
echo "==> Verifying"
docker exec hermes-agent rtk --version
echo "Done. Gateway listening on 127.0.0.1:8642"
