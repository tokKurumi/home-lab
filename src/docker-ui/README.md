# Portainer

A lightweight Docker UI management interface for easily managing containers, images, volumes, and networks.

## Quick Start

**Default setup (named volume)**:

```bash
docker compose up -d
```

**With custom storage path** (e.g., NAS, external drive):

```bash
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
```

Then access Portainer at http://localhost:9000 (if port is uncommented in `docker-compose.yml`).

## Ports

-   **Web UI**: http://localhost:9000 (commented out by default)
    -   Uncomment `ports:` section in `docker-compose.yml` to expose
    -   Intended for use with reverse proxy (e.g., via `proxiable` network)

## Configuration

### Environment Variables

All configuration is in `.env`:

-   **`HOST_PORTAINER_DATA`**: Path for bind-mount storage (optional)

    -   Only needed if using `docker-compose.bind.yml` override
    -   Examples: `./portainer/data`, `/mnt/nas/portainer/data`, `C:\data\portainer`

-   **`TZ`**: Timezone for Portainer (optional, defaults to `Europe/Moscow`)
    -   Examples: `UTC`, `America/New_York`, `Europe/London`

See `.env.example` for all available options.

## Storage

### Default: Named Volume (Recommended for most users)

Docker manages the volume automatically:

```bash
docker compose up -d
```

**Advantages**:

-   Zero configuration
-   Automatic backup with Docker commands
-   Portable across systems
-   Works immediately after cloning

**View volume location**:

```bash
docker volume inspect data
```

**Backup the volume**:

```bash
docker run --rm -v data:/data -v $(pwd):/backup alpine tar czf /backup/portainer-data-backup.tar.gz -C /data .
```

### Advanced: Bind Mount (For custom storage paths)

Store data in a specific directory on your host (local SSD, NAS mount, etc.):

1. **Edit `.env`**:

    ```env
    HOST_PORTAINER_DATA=/mnt/nas/portainer/data
    # or for relative path:
    # HOST_PORTAINER_DATA=./portainer/data
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
