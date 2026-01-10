# Vaultwarden Password Manager

A lightweight, self-hosted password manager and credential storage solution based on Bitwarden.

## Quick Start

**Default setup (named volume)**:

```bash
docker compose up -d
```

**With custom storage path** (e.g., NAS, external drive):

```bash
docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d
```

Or for maximum flexibility (per-service paths):

```bash
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
```

Then access Vaultwarden at http://localhost:8000 (if port is uncommented in `docker-compose.yml`).

## Ports

-   **Web UI**: http://localhost:8000 (commented out by default)
    -   Uncomment `ports:` section in `docker-compose.yml` to expose
    -   Intended for use with reverse proxy (e.g., via `proxiable` network)

## Configuration

### Environment Variables

All configuration is in `.env`:

-   **`VAULTWARDEN_DOMAIN`**: HTTPS domain where Vaultwarden is accessible (required)

    -   Example: `https://passwords.lan`, `https://vw.example.com`
    -   Used for correct redirect URIs and API calls from clients

-   **`HOST_VOLUMES_DIR`**: Base directory for named volumes with custom path (optional)
    -   Only needed if using `docker-compose.volumes.yml` override
    -   Default: `./docker-volumes` (relative to docker-compose file)
    -   Examples: `./docker-volumes`, `/mnt/nas/docker-volumes`, `/mnt/external-drive/docker-volumes`

-   **`HOST_VAULTWARDEN_DATA`**: Path for bind-mount storage (optional)
    -   Only needed if using `docker-compose.bind.yml` override
    -   Default: `./docker-volumes/password-store/vaultwarden`
    -   Examples: `/mnt/nas/vaultwarden`, `/mnt/external-drive/vaultwarden`

See `.env.example` for all available options.

## Storage

### Default: Named Volume

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
docker volume inspect vw-data
```

**Backup the volume**:

```bash
docker run --rm -v vw-data:/data -v $(pwd):/backup alpine tar czf /backup/vw-data-backup.tar.gz -C /data .
```

### Recommended: Named Volume with Custom Path

Store data on external storage (NAS, external drive) while keeping Docker's named volume management:

1. **Edit `.env`**:

    ```env
    HOST_VOLUMES_DIR=/mnt/nas/docker-volumes
    # or for relative path:
    # HOST_VOLUMES_DIR=./docker-volumes
    ```

2. **Start with volumes override**:
    ```bash
    docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d
    ```

**Advantages**:

-   ✅ Single environment variable controls all storage
-   ✅ Easy to change storage location (edit variable, migrate data)
-   ✅ Named volumes remain portable between hosts
-   ✅ Works with NAS (NFS, CIFS/SMB mounts) and cloud storage
-   ✅ Recommended for production

**Default directory structure**:

```
$HOST_VOLUMES_DIR/
└── password-store/
    └── vaultwarden/
```

### Advanced: Bind Mount

Store data with full control over individual service paths:

1. **Edit `.env`**:

    ```env
    HOST_VAULTWARDEN_DATA=/mnt/nas/vaultwarden
    # or for relative path:
    # HOST_VAULTWARDEN_DATA=./docker-volumes/password-store/vaultwarden
    ```

2. **Start with bind-mount override**:
    ```bash
    docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
    ```

**Advantages**:

-   Full control over storage location
-   Can point different services to different storage
-   Easy to back up / migrate data via filesystem commands
-   Integration with NAS (NFS, CIFS/SMB) or cloud mounts

## Networking

Vaultwarden connects to the `proxiable` network for integration with other services (e.g., reverse proxy). This network must exist or be created before starting:

```bash
docker network create proxiable
```

(Optional: managed by root `docker-compose.yml` if you have one)

## Logs

View container logs:

```bash
docker compose logs -f vaultwarden
```

## Tips

-   Vaultwarden by default allows anyone to register. Consider setting an invitation token in `.env` to restrict access.
-   Use a reverse proxy (Nginx, Traefik) on the `proxiable` network to securely expose with HTTPS
-   Database is stored as SQLite in the volume; consider external PostgreSQL for larger deployments

## Reverse Proxy Integration

To access Vaultwarden through Nginx Proxy Manager:

1. Uncomment ports in docker-compose.yml to expose locally
2. Or use Nginx as a reverse proxy with container name: `http://vaultwarden:80`
3. Ensure Nginx is in the `proxiable` network or connected to it
4. **Important**: Set `VAULTWARDEN_DOMAIN` in `.env` to match your reverse proxy domain (e.g., `https://passwords.example.com`)
