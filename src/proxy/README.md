# Nginx Proxy Manager

A reverse proxy and SSL certificate manager for secure HTTPS access to all home lab services.

## Quick Start

### Setup

1. **Create directory structure** (for volumes profile):
   ```bash
   ./prepare-volumes.sh
   ```

2. **Start services** (choose one option below):

   **Option 1: Named Volumes with Custom Path** (Recommended)
   ```bash
   # Set HOST_VOLUMES_DIR in .env if needed
   docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d
   ```

   **Option 2: Bind Mounts** (Alternative)
   ```bash
   # Set individual paths in .env
   docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
   ```

   **Option 3: Docker-managed Volumes** (Not Recommended)
   ```bash
   docker compose up -d
   ```

Then access the admin panel at **http://localhost:81**

## Ports

-   **Admin UI**: http://localhost:81
    -   Default credentials: `admin@example.com` / `changeme`
    -   Change immediately after first login

-   **HTTP Proxy**: http://localhost:80
    -   Automatically redirects to HTTPS for configured hosts

-   **HTTPS Proxy**: https://localhost:443
    -   Secure proxy with automatic Let's Encrypt certificate management

## Storage Configuration

This service supports three storage strategies:

| Strategy | Command | Data Location | Use Case |
|----------|---------|----------------|----------|
| **Named Volumes with Custom Path** ✅ | `docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d` | `$HOST_VOLUMES_DIR/proxy/nginx-proxy-manager/` | **Recommended** - Production and migration |
| **Bind Mounts** | `docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d` | Custom per-volume paths in `.env` | Advanced - Full granular control |
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
- All data persists in `$HOST_VOLUMES_DIR/proxy/nginx-proxy-manager/`

**Volume locations**:
```
$HOST_VOLUMES_DIR/proxy/
└── nginx-proxy-manager/
    ├── data/          (proxy configs, databases)
    └── letsencrypt/   (SSL certificates)

**Advantages**:

-   Full control over storage location
-   Easy to back up / migrate data via filesystem commands
-   Integration with NAS (NFS, CIFS/SMB) or cloud mounts

## Networking

The `proxiable` network is used to bridge all proxy manager services with other containers on the same network. This allows reverse proxy rules to route traffic to other services using container names instead of IPs.

Create the network if it doesn't exist:

```bash
docker network create proxiable
```

Other services connect to this network:

```yaml
networks:
    - proxiable
```

## Usage

### Adding a Proxy Host

1. Log in to admin panel: http://localhost:81
2. Go to **Proxy Hosts** → **Add Proxy Host**
3. Configure:
    - **Domain Names**: e.g., `dashboard.lan`, `passwords.lan`
    - **Scheme**: `http://` or `https://`
    - **Forward Hostname/IP**: Service name on `proxiable` network (e.g., `dashboard`, `vaultwarden`)
    - **Forward Port**: Service port (e.g., `7575`, `80`)
    - **SSL Certificate**: Request a new Let's Encrypt certificate (auto-renews)

### Example: Dashboard Behind Reverse Proxy

```yaml
# docker-compose.yml for dashboard (on proxiable network)
services:
    dashboard:
        networks:
            - proxiable
        # Remove or comment out ports to hide from host

networks:
    proxiable:
        external: true
```

Then configure in Proxy Manager:

-   Domain: `dashboard.lan`
-   Forward to: `http://dashboard:7575`
-   SSL: Enable with Let's Encrypt

## Logs

View container logs:

```bash
docker compose logs -f proxy
```

## Tips

-   Change the default admin password immediately after first login
-   Enable SSL certificates for all services exposed to the internet
-   Use container service names (not IPs) in proxy rules for reliability
-   Backup the `letsencrypt` volume regularly to preserve SSL certificates
