# Nginx Proxy Manager

A reverse proxy and SSL certificate manager for secure HTTPS access to all home lab services.

## Quick Start

**Default setup (named volumes)**:

```bash
docker compose up -d
```

**With custom storage path** (e.g., NAS, external drive):

```bash
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
```

Then access the admin panel at http://localhost:81

## Ports

-   **Admin UI**: http://localhost:81

    -   Default credentials: `admin@example.com` / `changeme`
    -   Change immediately after first login

-   **HTTP Proxy**: http://localhost:80

    -   Automatically redirects to HTTPS for configured hosts

-   **HTTPS Proxy**: https://localhost:443
    -   Secure proxy with automatic Let's Encrypt certificate management

## Configuration

### Environment Variables

All configuration is in `.env`:

-   **`HOST_NGINX_PROXY_MANAGER_DATA`**: Path for bind-mount storage of configuration (optional)

    -   Only needed if using `docker-compose.bind.yml` override
    -   Examples: `./nginx-proxy-manager/data`, `/mnt/nas/nginx-proxy-manager/data`, `C:\data\nginx-proxy-manager`

-   **`HOST_NGINX_PROXY_MANAGER_LETSENCRYPT`**: Path for bind-mount storage of SSL certificates (optional)

    -   Only needed if using `docker-compose.bind.yml` override
    -   Examples: `./nginx-proxy-manager/letsencrypt`, `/mnt/nas/nginx-proxy-manager/letsencrypt`

-   **`ADMIN_USER`**: Initial admin email (optional, defaults to `admin@example.com`)

-   **`ADMIN_PASSWORD`**: Initial admin password (optional, defaults to `changeme`)

See `.env.example` for all available options.

## Storage

### Default: Named Volumes (Recommended for most users)

Docker manages the volumes automatically:

```bash
docker compose up -d
```

**Advantages**:

-   Zero configuration
-   Automatic backup with Docker commands
-   Portable across systems
-   Works immediately after cloning

**View volumes**:

```bash
docker volume ls
docker volume inspect data
docker volume inspect letsencrypt
```

**Backup the volumes**:

```bash
docker run --rm -v data:/data -v $(pwd):/backup alpine tar czf /backup/nginx-proxy-manager-data-backup.tar.gz -C /data .
docker run --rm -v letsencrypt:/certs -v $(pwd):/backup alpine tar czf /backup/nginx-proxy-manager-letsencrypt-backup.tar.gz -C /certs .
```

### Advanced: Bind Mount (For custom storage paths)

Store data in specific directories on your host (local SSD, NAS mount, etc.):

1. **Edit `.env`**:

    ```env
    HOST_NPM_DATA=/mnt/nas/npm/data
    HOST_NPM_LETSENCRYPT=/mnt/nas/npm/letsencrypt
    # or for relative paths:
    # HOST_NPM_DATA=./npm/data
    # HOST_NPM_LETSENCRYPT=./npm/letsencrypt
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
