# Portainer

A lightweight Docker UI management interface for easily managing containers, images, volumes, and networks.

## Quick Start

```bash
# Named volumes with custom path (recommended)
docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d

# Or: Bind mounts for advanced per-service customization
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d

# Or: Docker-managed volumes (testing only, not recommended)
docker compose up -d
```

Access Portainer at http://localhost:9000 (if port is uncommented in `docker-compose.yml`).

## Ports

-   **Web UI**: http://localhost:9000 (commented out by default)
    -   Uncomment `ports:` section in `docker-compose.yml` to expose
    -   Intended for use with reverse proxy (e.g., via `proxiable` network)

## Storage Strategies

| Strategy | Command | Use Case |
|----------|---------|----------|
| **Named Volumes** ✅ | `-f docker-compose.volumes.yml` | Recommended - data on custom path |
| **Bind Mounts** | `-f docker-compose.bind.yml` | Advanced - direct path control |
| **Docker Volumes** ⚠️ | *(no override)* | Testing only - system drive |

### Named Volumes with Custom Path (Recommended) ✅

Data stored in `./docker-volumes/docker-ui/portainer` (or custom path):

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
HOST_PORTAINER_DATA=/mnt/nas/docker-ui/portainer
# or relative:
# HOST_PORTAINER_DATA=./docker-volumes/docker-ui/portainer
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

-   **`HOST_PORTAINER_DATA`**: Custom path for Portainer data (bind mounts profile only)
    -   Examples: `/mnt/nas/docker-ui/portainer`, `./docker-volumes/docker-ui/portainer`

-   **`TZ`**: Timezone for Portainer (optional, defaults to `Europe/Moscow`)
    -   Examples: `UTC`, `America/New_York`, `Europe/London`

See `.env.example` for all available options.

## Setup

Prepare volume directories:

```bash
./prepare-volumes.sh
```

This creates the necessary directory structure with proper permissions.

## Networking

Portainer uses two networks:

1. **`portainer_network`**: Internal bridge network for Portainer communication
2. **`proxiable`**: Shared network for integration with other services (e.g., reverse proxy)

The `proxiable` network must exist or be created before starting:

```bash
docker network create proxiable
```

(Optional: managed by root `docker-compose.yml` if you have one)

## Usage

### First Login

1. Access Portainer at http://localhost:9000 or via reverse proxy
2. Create admin account with username and password
3. Connect to local Docker socket (already configured)

### Managing Containers

-   **Containers**: View, create, start, stop, and remove containers
-   **Images**: Pull, view, and remove Docker images
-   **Volumes**: Manage Docker volumes and bind mounts
-   **Networks**: View and manage Docker networks
-   **Stacks**: Deploy and manage Docker Compose applications

## Logs

View container logs:

```bash
docker compose logs -f portainer
```

## Tips

-   Portainer is stateless except for its configuration stored in the `data` volume
-   Always backup the `data` volume before major updates
-   Use reverse proxy for secure HTTPS access
-   Portainer can manage multiple Docker hosts if configured
-   The watchtower label enables automatic updates for Portainer itself

## Reverse Proxy Integration

To access Portainer through Nginx Proxy Manager:

1. Uncomment ports in docker-compose.yml to expose locally
2. Or use Nginx as a reverse proxy with container name: `http://portainer:9000`
3. Ensure Nginx is in the `proxiable` network or connected to it
