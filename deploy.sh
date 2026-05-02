#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE="hermes-agent-local:latest"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

echo "==> Building $IMAGE"
docker build -t "$IMAGE" "$SCRIPT_DIR"

echo "==> Restarting container"
docker-compose -f "$COMPOSE_FILE" up -d --force-recreate

echo "==> Verifying"
docker exec hermes-agent rtk --version
echo "Done."
