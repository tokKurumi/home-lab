# Media Server Stack

A comprehensive automated media management and streaming stack with VPN protection, torrent downloading, and content organization.

## Components

-   **WireGuard**: VPN gateway for secure and private torrenting
-   **qBittorrent**: Torrent client (routed through VPN)
-   **Prowlarr**: Indexer manager for automated torrent searches
-   **Sonarr**: TV series automation and management
-   **Radarr**: Movie automation and management
-   **Lidarr**: Music automation and management
-   **FileFlows**: Automated media file processing and transcoding
-   **Jellyfin**: Media streaming server with hardware acceleration
-   **Jellyseerr**: User request management for media content
-   **Discord Music Bot**: Play music from Jellyfin in Discord voice channels

## Quick Start

**Default setup (named volumes)**:

```bash
docker compose up -d
```

**With custom storage path** (e.g., NAS, external drive):

```bash
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
```

## Ports

-   **qBittorrent Web UI**: http://localhost:8080 (via WireGuard container)
-   **Prowlarr**: http://localhost:9696 (hidden by default, access via reverse proxy)
-   **Lidarr**: http://localhost:8686 (hidden by default, access via reverse proxy)
-   **Radarr**: http://localhost:7878 (hidden by default, access via reverse proxy)
-   **Sonarr**: http://localhost:8989 (hidden by default, access via reverse proxy)
-   **FileFlows**: http://localhost:19200 (hidden by default, access via reverse proxy)
-   **Jellyfin**: http://localhost:8096 (hidden by default, access via reverse proxy)
    -   Local discovery: UDP 7359
    -   DLNA: UDP 1900
-   **Jellyseerr**: http://localhost:5055 (hidden by default, access via reverse proxy)

## Configuration

### Environment Variables

All configuration is in `.env`:

```bash
cp .env.example .env
# Edit .env with your settings
```

Key variables:

-   **WireGuard VPN**: `WIREGUARD_ENDPOINT_IP`, `WIREGUARD_PUBLIC_KEY`, `WIREGUARD_PRIVATE_KEY`

    -   Generate client keys: `wg genkey | tee privatekey | wg pubkey > publickey`
    -   Server-side configuration is managed by your VPN provider

-   **qBittorrent**: `QBIT_WEBUI_PORT` (default: 8080), `QBIT_CONNECTION_PORT` (default: 6881)

    -   Default password: `9ec849e7-3d42-4a33-9a6d-49670334f983`

-   **Discord Bot**: `DISCORD_CLIENT_TOKEN`, `JELLYFIN_AUTHENTICATION_USERNAME`, `JELLYFIN_AUTHENTICATION_PASSWORD`

    -   Create bot at https://discord.com/developers/applications

-   **Storage Paths** (for bind-mount mode): `HOST_MEDIA_DATA`, `HOST_*_CONFIG`

-   **User/System**: `PUID`, `PGID` (find with `id -u` and `id -g`), `TZ`

See `.env.example` for all available options.

### WireGuard VPN Setup

1. Obtain VPN credentials from your provider (endpoint IP, port, server public key)
2. Generate client keys:
    ```bash
    wg genkey | tee privatekey | wg pubkey > publickey
    wg genpsk > preshared_key
    ```
3. Add keys to `.env`:
    ```env
    WIREGUARD_ENDPOINT_IP=vpn.example.com
    WIREGUARD_ENDPOINT_PORT=51820
    WIREGUARD_PUBLIC_KEY=$(cat publickey)
    WIREGUARD_PRIVATE_KEY=$(cat privatekey)
    WIREGUARD_PRESHARED_KEY=$(cat preshared_key)
    WIREGUARD_ADDRESSES=10.8.0.1/24
    ```
4. Copy WireGuard config template:
    ```bash
    cp media/configs/wireguard/wg_confs/wg0.conf.example media/configs/wireguard/wg_confs/wg0.conf
    # Edit wg0.conf with your VPN details
    ```

## Storage

### Default: Named Volumes (Recommended for most users)

Docker manages all volumes automatically:

```bash
docker compose up -d
```

**Advantages**:

-   Zero configuration
-   Automatic backup with Docker commands
-   Portable across systems
-   Works immediately after cloning

**Volumes created**:

-   `wireguard-config`, `qbittorrent-config`, `prowlarr-config`
-   `lidarr-config`, `radarr-config`, `sonarr-config`
-   `fileflows-temp`, `fileflows-data`, `fileflows-common`
-   `jellyfin-config`, `jellyseerr-config`
-   `media-data` (shared by all services for downloads/library)

**View volumes**:

```bash
docker volume ls | grep media
docker volume inspect media-data
```

**Backup volumes**:

```bash
docker run --rm -v media-data:/data -v $(pwd):/backup alpine tar czf /backup/media-data-backup.tar.gz -C /data .
```

### Advanced: Bind Mount (For custom storage paths)

Store data in specific directories on your host (NAS, external drives, etc.):

1. **Edit `.env`**:

    ```env
    HOST_MEDIA_DATA=/mnt/nas/media/data
    HOST_JELLYFIN_CONFIG=/mnt/nas/media/configs/jellyfin
    # ... or use relative paths:
    # HOST_MEDIA_DATA=./media/data
    # HOST_JELLYFIN_CONFIG=./media/configs/jellyfin
    ```

2. **Start with override**:
    ```bash
    docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
    ```

**Advantages**:

-   Full control over storage location
-   Easy to back up / migrate data via filesystem commands
-   Integration with NAS (NFS, CIFS/SMB) or cloud mounts

## Network Topology

The stack uses two networks:

-   **media_network** (internal): For communication between media stack components
-   **proxiable** (external): For access through a reverse proxy (Nginx Proxy Manager, etc.)

All services automatically discover each other by container name (Docker DNS).

**Note**: qBittorrent uses `network_mode: service:wireguard`, routing all traffic through the VPN. Access qBittorrent Web UI via WireGuard container port.

Create the `proxiable` network if it doesn't exist:

```bash
docker network create proxiable
```

## GPU Hardware Acceleration

**Jellyfin** and **FileFlows** are configured with NVIDIA GPU support for hardware-accelerated transcoding.

**Requirements**:

-   NVIDIA GPU with driver installed
-   NVIDIA Container Toolkit: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

**Verify GPU access**:

```bash
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

If you don't have an NVIDIA GPU, remove the `devices` and `NVIDIA_*` environment variables from Jellyfin and FileFlows services.

## Usage

### Initial Setup Sequence

1. **Start WireGuard** and verify VPN connection
2. **Configure Prowlarr** with indexers
3. **Connect Sonarr/Radarr/Lidarr** to Prowlarr and qBittorrent
4. **Set up FileFlows** processing rules
5. **Add media libraries** to Jellyfin
6. **Connect Jellyseerr** to Jellyfin

### Media Organization

Recommended folder structure in `media-data` volume (or `HOST_MEDIA_DATA`):

```
/media/
  ├── downloads/       # qBittorrent downloads
  ├── movies/          # Radarr managed
  ├── tv/              # Sonarr managed
  ├── music/           # Lidarr managed
  └── processing/      # FileFlows temp
```

Configure each \*arr application to use these paths.

## Logs

View logs for any service:

```bash
docker compose logs -f jellyfin
docker compose logs -f qbittorrent
docker compose logs -f wireguard
```

## Backup

**Named volumes**:

```bash
# Backup media data
docker run --rm -v media-data:/data -v $(pwd):/backup alpine tar czf /backup/media-data-backup.tar.gz -C /data .

# Backup configurations
for vol in wireguard-config qbittorrent-config prowlarr-config; do
  docker run --rm -v $vol:/data -v $(pwd):/backup alpine tar czf /backup/$vol-backup.tar.gz -C /data .
done
```

**Bind mounts**: Use standard filesystem backup tools (rsync, tar, etc.)

## Reverse Proxy Integration

To access services through Nginx Proxy Manager:

### Jellyfin (Media Server)

-   Container name: `http://jellyfin:8096`
-   Recommended domain: `jellyfin.lan` or `jellyfin.example.com`

### Jellyseerr (Request Manager)

-   Container name: `http://jellyseerr:5055`
-   Recommended domain: `requests.lan` or `requests.example.com`

### Prowlarr (Indexers)

-   Container name: `http://prowlarr:9696`
-   Recommended domain: `prowlarr.lan` (internal only)

### Sonarr (TV)

-   Container name: `http://sonarr:8989`
-   Recommended domain: `sonarr.lan` (internal only)

### Radarr (Movies)

-   Container name: `http://radarr:7878`
-   Recommended domain: `radarr.lan` (internal only)

### Lidarr (Music)

-   Container name: `http://lidarr:8686`
-   Recommended domain: `lidarr.lan` (internal only)

### FileFlows (Processing)

-   Container name: `http://fileflows:5000`
-   Recommended domain: `fileflows.lan` (internal only)

### qBittorrent (Torrent Client)

-   Accessed via WireGuard container: `http://wireguard:8080`
-   **Important**: Only expose via reverse proxy if you trust your network (VPN protected)

**Setup**:

1. Ensure Nginx is in the `proxiable` network
2. All services are already connected to `proxiable` network
3. Create proxy hosts in Nginx Proxy Manager using container names above

## Security Notes

-   All torrent traffic is routed through WireGuard VPN
-   qBittorrent is not directly exposed; access only through WireGuard container
-   Never expose \*arr applications to the public internet (use VPN or private network)
-   Change default qBittorrent password immediately after first login
-   Use strong credentials for Jellyfin admin account

## Troubleshooting

**VPN not connecting**:

-   Check WireGuard logs: `docker compose logs -f wireguard`
-   Verify credentials in `.env` match VPN provider settings
-   Ensure WireGuard config file is correct

**qBittorrent not accessible**:

-   Access via WireGuard container port (default: http://localhost:8080)
-   Check that WireGuard is running: `docker ps | grep wireguard`

**Jellyfin hardware acceleration not working**:

-   Verify NVIDIA driver: `nvidia-smi`
-   Check GPU access in container: `docker exec -it jellyfin nvidia-smi`
-   Install NVIDIA Container Toolkit if missing

**Services can't reach each other**:

-   Verify all services are on `media_network`: `docker network inspect media_network`
-   Use container names for communication (e.g., `http://jellyfin:8096`, not `localhost`)

## Credits

-   [LinuxServer.io](https://www.linuxserver.io/) for Docker images
-   [\*arr Community](https://wiki.servarr.com/) for automation tools
-   [Jellyfin Project](https://jellyfin.org/)
-   [WireGuard](https://www.wireguard.com/)

---

**Enjoy your automated media server!**
