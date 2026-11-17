#!/usr/bin/env bash
# Rebuild Valhalla's routing tiles from a fresh OSM extract (run on the host).
#   ./rebuild.sh                      # uses data/*.osm.pbf (e.g. copied from navigo-otp)
set -euo pipefail
cd "$(dirname "$0")"
COMPOSE="docker compose -f ${COMPOSE_FILE:-docker-compose.yml}"

ls data/*.osm.pbf >/dev/null 2>&1 || { echo "No data/*.osm.pbf found. Copy the OSM extract first."; exit 1; }

echo "[valhalla] Removing old tiles"
rm -rf data/valhalla_tiles data/valhalla_tiles.tar data/file_hashes.txt

echo "[valhalla] Restarting: tiles are rebuilt on start"
$COMPOSE up -d --force-recreate valhalla

echo "[valhalla] Waiting for /status"
for i in $(seq 1 160); do
  if curl -sf http://127.0.0.1:8002/status >/dev/null; then echo "[valhalla] Ready"; exit 0; fi
  sleep 15
done
echo "[valhalla] Not ready after 40 min, check: docker logs navigo-valhalla"; exit 1
