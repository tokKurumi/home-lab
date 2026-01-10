#!/bin/bash
# Prepare directory structure for volumes profile
# Usage: ./prepare-volumes.sh

set -e

# Read HOST_VOLUMES_DIR from environment or use default
BASE_DIR="${HOST_VOLUMES_DIR:-./docker-volumes}"

echo "Creating directory structure in: $BASE_DIR"

# Create all required directories
mkdir -p "$BASE_DIR/password-store/vaultwarden"

# Set ownership for entire password-store stack
# Vaultwarden runs as UID 911 (default user in vaultwarden/server image)
echo ""
echo "Setting ownership to 911:911..."
chown -R 911:911 "$BASE_DIR/password-store"

echo "✓ Directory structure created successfully:"
tree -L 4 "$BASE_DIR" 2>/dev/null || find "$BASE_DIR" -type d | sort

echo ""
echo "You can now run:"
echo "  docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d"
