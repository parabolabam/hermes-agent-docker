#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE="hermes-agent-local:latest"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

echo "==> Building $IMAGE"
docker build -t "$IMAGE" "$SCRIPT_DIR"

echo "==> Restarting container"
# Support both docker compose v2 (plugin) and docker-compose v1 (standalone)
if docker compose version >/dev/null 2>&1; then
  docker compose -f "$COMPOSE_FILE" up -d --force-recreate
else
  docker-compose -f "$COMPOSE_FILE" up -d --force-recreate
fi

echo "==> Verifying"
docker exec hermes-agent rtk --version
echo "Done."
