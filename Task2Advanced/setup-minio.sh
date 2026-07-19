#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> Starting MinIO container..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d

echo ">>> Waiting for MinIO to be ready..."
until curl -s http://localhost:9000/minio/health/live > /dev/null 2>&1; do
  sleep 2
done
echo ">>> MinIO is ready"

echo ">>> Creating 'tfstate' bucket..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" exec -T minio \
  mc alias set local http://localhost:9000 minioadmin minioadmin 2>/dev/null
docker compose -f "$SCRIPT_DIR/docker-compose.yml" exec -T minio \
  mc mb local/tfstate --ignore-existing 2>/dev/null

echo ">>> Bucket 'tfstate' ready"
echo ">>> MinIO console: http://localhost:9001 (login: minioadmin / minioadmin)"
