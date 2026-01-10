# OpenSpeedTest

A lightweight, open-source internet speed testing application.

## Quick Start

### Setup

1. **Create directory structure** (for volumes profile):
   ```bash
   ./prepare-volumes.sh
   ```

2. **Start service** (choose one option below):

   **Option 1: Named Volumes with Custom Path** (Recommended)
   ```bash
   # Set HOST_VOLUMES_DIR in .env if needed
   docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d
   ```

   **Option 2: Bind Mounts** (Alternative)
   ```bash
   # Set HOST_SPEEDTEST_APPDATA in .env
   docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
   ```

   **Option 3: Docker-managed Volumes** (Not Recommended)
   ```bash
   docker compose up -d
   ```

Then access OpenSpeedTest at **http://localhost:3000** (if ports are uncommented in `docker-compose.yml`).

## Ports

-   **Web UI**: http://localhost:3000 (commented out by default)
    -   API: http://localhost:3001
    -   Uncomment `ports:` section in `docker-compose.yml` to expose
    -   Intended for use with reverse proxy (e.g., via `proxiable` network)

## Storage Configuration

This service supports three storage strategies:

| Strategy | Command | Data Location | Use Case |
|----------|---------|----------------|----------|
| **Named Volumes with Custom Path** ✅ | `docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d` | `$HOST_VOLUMES_DIR/speedtest/openspeedtest/` | **Recommended** - Production and migration |
| **Bind Mounts** | `docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d` | Custom path in `.env` | Advanced - Full granular control |
| **Docker-managed Volumes** ⚠️ | `docker compose up -d` | `/var/lib/docker/volumes/` | Development/testing only |

### Recommended Setup (Named Volumes)

This approach provides:
- ✅ Data stored on your chosen drive (external SSD, NAS, etc.)
- ✅ Named volumes (portable, Docker-native)
- ✅ Single configuration variable (`HOST_VOLUMES_DIR`)
- ✅ Easy migration to new servers

**Configuration**:

```env
# .env
HOST_VOLUMES_DIR=/mnt/big-hard-drive/docker-volumes

# If not set, defaults to ./docker-volumes in current directory
```

**How it works**:
- `docker-compose.yml` defines the service and volume names
- `docker-compose.volumes.yml` maps those named volumes to paths on your disk
- Docker creates volumes automatically at startup
- All data persists in `$HOST_VOLUMES_DIR/speedtest/openspeedtest/`

**Volume locations**:
```
$HOST_VOLUMES_DIR/speedtest/
└── openspeedtest/
    └── appdata/    (speedtest data and configuration)
```

## Configuration

### Environment Variables

All configuration is in `.env`:

-   **`HOST_VOLUMES_DIR`**: Base directory for all volumes (for named volumes profile)
    -   Examples: `/mnt/nas/docker-volumes`, `/mnt/ssd/docker-volumes`
    -   Default: `./docker-volumes`

-   **`HOST_SPEEDTEST_APPDATA`**: Path for bind-mount storage (optional)
    -   Only needed if using `docker-compose.bind.yml` override
    -   Examples: `./docker-volumes/speedtest/openspeedtest/appdata`, `/mnt/nas/speedtest/appdata`

See `.env.example` for all available options.

## Storage

### Default: Named Volumes with Custom Path (Recommended)

Docker manages the volume automatically with a custom path:

```bash
docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d
```

**Advantages**:

-   Zero configuration (optional)
-   Automatic backup with Docker commands
-   Portable across systems
-   Works immediately after cloning

**View volume location**:

```bash
docker volume inspect appdata
```

**Backup the volume**:

```bash
docker run --rm -v appdata:/data -v $(pwd):/backup alpine tar czf /backup/speedtest-appdata-backup.tar.gz -C /data .
```

### Advanced: Bind Mount (For custom storage paths)

Store data in a specific directory on your host (local SSD, NAS mount, etc.):

1. **Edit `.env`**:

    ```env
    HOST_SPEEDTEST_APPDATA=/mnt/nas/speedtest/appdata
    # or for relative path:
    # HOST_SPEEDTEST_APPDATA=./speedtest/appdata
    ```

2. **Start with override**:
    ```bash
    docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
    ```

**Advantages**:

-   Full control over storage location
-   Easy to back up / migrate data via filesystem commands
-   Integration with NAS (NFS, CIFS/SMB) or cloud mounts

## Networking

OpenSpeedTest connects to the `proxiable` network for integration with other services (e.g., reverse proxy). This network must exist or be created before starting:

```bash
docker network create proxiable
```

(Optional: managed by root `docker-compose.yml` if you have one)

## Usage

Access the speed test interface at the configured domain/port and run internet speed tests.

## Logs

View container logs:

```bash
docker compose logs -f speedtest
```

## Tips

-   Use a reverse proxy (Nginx, Traefik) on the `proxiable` network to expose with a domain name
-   Test results and configuration data are stored in the `appdata` volume
-   The service is lightweight and suitable for home lab environments

## Reverse Proxy Integration

To access OpenSpeedTest through Nginx Proxy Manager:

1. Uncomment ports in docker-compose.yml to expose locally
2. Or use Nginx as a reverse proxy with container name: `http://speedtest:3000`
3. Ensure Nginx is in the `proxiable` network or connected to it
