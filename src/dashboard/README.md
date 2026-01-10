# Homarr Dashboard

A customizable, self-hosted dashboard to monitor and control home lab services.

## Quick Start

```bash
# Named volumes with custom path (recommended)
docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d

# Or: Bind mounts for advanced per-service customization
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d

# Or: Docker-managed volumes (testing only, not recommended)
docker compose up -d
```

Access the dashboard at http://localhost:7575 (if port is uncommented in `docker-compose.yml`).

## Ports

-   **Web UI**: http://localhost:7575 (commented out by default)
    -   Uncomment `ports:` section in `docker-compose.yml` to expose

## Storage Strategies

| Strategy | Command | Use Case |
|----------|---------|----------|
| **Named Volumes** ✅ | `-f docker-compose.volumes.yml` | Recommended - data on custom path |
| **Bind Mounts** | `-f docker-compose.bind.yml` | Advanced - direct path control |
| **Docker Volumes** ⚠️ | *(no override)* | Testing only - system drive |

### Named Volumes with Custom Path (Recommended) ✅

Data stored in `./docker-volumes/dashboard/homarr` (or custom path):

```bash
docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d
```

**Benefits**:
- ✅ Single `HOST_VOLUMES_DIR` variable controls all stacks
- ✅ Portable between hosts
- ✅ Easy migration: change variable, copy directory
- ✅ Works with NAS, external drives, cloud mounts

**Custom storage path** (via `.env`):

```env
HOST_VOLUMES_DIR=/mnt/nas/docker-volumes
```

Default: `./docker-volumes`

### Bind Mounts (Advanced - Per-Service Control)

Direct host path for fine-grained control:

```bash
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
```

**Configure in `.env`**:

```env
HOST_HOMARR_APPDATA=/mnt/nas/dashboard/homarr
# or relative:
# HOST_HOMARR_APPDATA=./docker-volumes/dashboard/homarr
```

**Benefits**:
- ✅ Individual variable per volume
- ✅ Mix multiple storage backends
- ✅ Full control over paths

### Docker-Managed Volumes (Not Recommended) ⚠️

System-managed volumes in `/var/lib/docker/volumes/`:

```bash
docker compose up -d
```

**Limitations**:
- ❌ Hard to find data on disk
- ❌ Not portable between hosts
- ❌ Difficult to migrate

**Only use for**: Testing, temporary deployments

## Configuration

All configuration is in `.env`:

-   **`HOST_VOLUMES_DIR`**: Base directory for all volumes (named volumes profile)
    -   Examples: `./docker-volumes`, `/mnt/nas/docker-volumes`, `/mnt/storage/docker-volumes`

-   **`HOST_HOMARR_APPDATA`**: Custom path for dashboard data (bind mounts profile only)
    -   Examples: `/mnt/nas/dashboard/homarr`, `./docker-volumes/dashboard/homarr`

-   **`SECRET_ENCRYPTION_KEY`**: Encryption key for dashboard data (required)
    -   Generate with: `openssl rand -hex 32`

See `.env.example` for all available options.

## Setup

Prepare volume directories:

```bash
./prepare-volumes.sh
```

This creates the necessary directory structure with proper permissions.

## Networking

The dashboard connects to the `proxiable` network for integration with other services (e.g., reverse proxy). This network must exist or be created before starting:

```bash
docker network create proxiable
```

(Optional: managed by root `docker-compose.yml` if you have one)

## Logs

View container logs:

```bash
docker compose logs -f dashboard
```

## Stop / Restart

```bash
# Stop the service
docker compose down

# Restart
docker compose up -d
```

## Security Notes

-   **Never commit `.env`** to git (it's in `.gitignore`)
-   All secrets must be in `.env` (not in docker-compose files)
-   Use strong, random `SECRET_ENCRYPTION_KEY` values
-   Keep Docker daemon socket access restricted if exposing the dashboard

## Troubleshooting

**"Connection refused" on port 7575**:

-   Port is commented out by default. Uncomment `ports:` in `docker-compose.yml`.

**Volume permission errors**:

-   For bind mounts: ensure the host directory exists and has appropriate permissions.
-   For named volumes: check `docker volume inspect appdata` for location and access.

**Network errors**:

-   Ensure `proxiable` network exists: `docker network create proxiable`

## Reverse Proxy Integration

To access the dashboard through Nginx Proxy Manager:

1. Uncomment ports in docker-compose.yml to expose locally
2. Or use Nginx as a reverse proxy with container name: `http://dashboard:7575`
3. Ensure Nginx is in the `proxiable` network or connected to it

## See Also

-   [Homarr Project](https://github.com/homarr-labs/homarr)
