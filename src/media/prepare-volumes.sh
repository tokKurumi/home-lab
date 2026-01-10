#!/bin/bash
# Prepare directory structure for volumes profile
# Usage: ./prepare-volumes.sh

set -e

# Read HOST_VOLUMES_DIR from environment or use default
BASE_DIR="${HOST_VOLUMES_DIR:-./docker-volumes}"

echo "Creating directory structure in: $BASE_DIR"

# Create all required directories
mkdir -p "$BASE_DIR/media/config/wireguard"
mkdir -p "$BASE_DIR/media/config/qbittorrent"
mkdir -p "$BASE_DIR/media/config/prowlarr"
mkdir -p "$BASE_DIR/media/config/lidarr"
mkdir -p "$BASE_DIR/media/config/radarr"
mkdir -p "$BASE_DIR/media/config/sonarr"
mkdir -p "$BASE_DIR/media/config/jellyfin"
mkdir -p "$BASE_DIR/media/config/jellyseerr"
mkdir -p "$BASE_DIR/media/fileflows/temp"
mkdir -p "$BASE_DIR/media/fileflows/data"
mkdir -p "$BASE_DIR/media/fileflows/common"
mkdir -p "$BASE_DIR/media/data"

# Copy default config files if they don't exist
echo ""
echo "Copying default configuration files..."

# WireGuard default config
if [ ! -f "$BASE_DIR/media/config/wireguard/wg_confs/wg0.conf" ]; then
  mkdir -p "$BASE_DIR/media/config/wireguard/wg_confs"
  cp config/wireguard/wg_confs/wg0.conf.example "$BASE_DIR/media/config/wireguard/wg_confs/wg0.conf"
  echo "  ✓ Copied wg0.conf"
fi

# qBittorrent default config
if [ ! -f "$BASE_DIR/media/config/qbittorrent/qBittorrent/categories.json" ]; then
  mkdir -p "$BASE_DIR/media/config/qbittorrent/qBittorrent"
  cp config/qbittorrent/qBittorrent/categories.json "$BASE_DIR/media/config/qbittorrent/qBittorrent/categories.json"
  echo "  ✓ Copied categories.json"
fi

echo ""
echo "✓ Directory structure created successfully:"
tree -L 3 "$BASE_DIR" 2>/dev/null || find "$BASE_DIR" -type d | sort

echo ""
echo "You can now run:"
echo "  docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d"
