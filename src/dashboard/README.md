# Homarr Dashboard

A customizable, self-hosted dashboard to monitor and control home lab services.

## Quick Start

**Default setup (named volume)**:
```bash
docker compose up -d
```

**With custom storage path** (e.g., NAS, external drive):
```bash
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
```

Then access the dashboard at http://localhost:7575 (if port is uncommented in `docker-compose.yml`).

## Ports

- **Web UI**: http://localhost:7575 (commented out by default)
  - Uncomment `ports:` section in `docker-compose.yml` to expose

## Configuration

### Environment Variables

All configuration is in `.env`:

- **`SECRET_ENCRYPTION_KEY`**: Encryption key for dashboard data (required)
  - Generate with: `openssl rand -hex 32`
  - See `.env.example` for details

- **`HOST_APPDATA`**: Path for bind-mount storage (optional)
  - Only needed if using `docker-compose.bind.yml` override
  - Examples: `./homarr/appdata`, `/mnt/nas/homarr`, `C:\data\homarr`

See `.env.example` for all available options.

## Storage

### Default: Named Volume (Recommended for most users)

Docker manages the volume automatically:
```bash
docker compose up -d
```

**Advantages**:
- Zero configuration
- Automatic backup with Docker commands
- Portable across systems
- Works immediately after cloning

**View volume location**:
```bash
docker volume inspect appdata
```

**Backup the volume**:
```bash
docker run --rm -v appdata:/data -v $(pwd):/backup alpine tar czf /backup/appdata-backup.tar.gz -C /data .
```

### Advanced: Bind Mount (For custom storage paths)

Store data in a specific directory on your host (local SSD, NAS mount, etc.):

1. **Edit `.env`**:
   ```env
   HOST_APPDATA=/mnt/nas/homarr
   # or for relative path:
   # HOST_APPDATA=./homarr/appdata
   ```

2. **Start with override**:
   ```bash
   docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
   ```

**Advantages**:
- Full control over storage location
- Easy to back up / migrate data via filesystem commands
- Integration with NAS (NFS, CIFS/SMB) or cloud mounts

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

- **Never commit `.env`** to git (it's in `.gitignore`)
- All secrets must be in `.env` (not in docker-compose files)
- Use strong, random `SECRET_ENCRYPTION_KEY` values
- Keep Docker daemon socket access restricted if exposing the dashboard

## Troubleshooting

**"Connection refused" on port 7575**:
- Port is commented out by default. Uncomment `ports:` in `docker-compose.yml`.

**Volume permission errors**:
- For bind mounts: ensure the host directory exists and has appropriate permissions.
- For named volumes: check `docker volume inspect appdata` for location and access.

**Network errors**:
- Ensure `proxiable` network exists: `docker network create proxiable`

## See Also

- [Homarr Project](https://github.com/homarr-labs/homarr)
