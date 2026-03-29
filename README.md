# Home Lab: Lightweight Self-Hosted Media & Services Platform

A comprehensive, containerized home media server and laboratory environment designed for minimal setup, maximum flexibility, and production-grade reliability. Run sophisticated services—from media streaming to reverse proxying to monitoring—with **zero system-wide dependencies**.

**Status**: ✅ Production-ready | 🐳 100% containerized | 🔧 Zero-config defaults | 🚀 Easy migration

---

## What Is This?

This project provides a **modular, Docker Compose-based infrastructure** for running personal services at home:

### 🎯 Why Home Lab?

- **Privacy First**: Keep your data on your own hardware, no cloud vendor lock-in
- **Cost-Effective**: Reuse old hardware; minimal power consumption with efficient containers
- **Learning**: Hands-on experience with Docker, networking, infrastructure patterns
- **Flexibility**: Mix and match services to build your ideal setup
- **Reproducibility**: Start fresh on new hardware by copying a few directories

### 💡 Key Philosophy

- **Works out-of-the-box**: Start any service with `docker compose up -d`
- **Progressive complexity**: Beginners use defaults, advanced users customize storage and networking
- **Portable data**: Move services between hosts without redeployment

---

## Quick Start

### 1. Prerequisites

- **Docker** and **Docker Compose**
- **Linux** (Ubuntu, Debian, Fedora, etc.), **macOS**, or **Windows with WSL2**
- ~2GB free disk space (grows with media content)
- 4+ GB RAM recommended for media services

### 2. Clone the Repository

```bash
git clone https://github.com/yourusername/home-lab.git
cd home-lab
```

### 3. Start Your First Service

```bash
# Option A: Dashboard (fastest)
cd src/dashboard
docker compose up -d

# Access at http://localhost:7575 (if port uncommented)
# Check logs: docker compose logs -f

# Option B: Full media stack
cd src/media
docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d
```

### 4. Verify It's Running

```bash
docker compose ps
# You should see all services with "Up" status
```

### 5. Next Steps

- Review the service-specific [README](#available-services) (e.g., `src/media/README.md`)
- Configure `.env` for custom storage paths and secrets
- Set up reverse proxy for remote access: see [Reverse Proxy Setup](#reverse-proxy-secure-remote-access)

---

## Available Services

Each service is independently deployable. Mix and match to build your setup:

### 🎨 **Dashboards & UI**

| Service | Purpose | Quick Start |
|---------|---------|-------------|
| **Dashboard** | Central hub to monitor & control all services | `cd src/dashboard && docker compose up -d` |
| **Docker UI** | Visual container management interface | `cd src/docker-ui && docker compose up -d` |

### 📺 **Media Management** (Multi-Service Stack)

| Component | Purpose |
|-----------|---------| 
| **WireGuard** | VPN gateway for encrypted, private torrenting |
| **qBittorrent** | Torrent client (optional VPN routing) |
| **Prowlarr** | Indexer manager for automated searches |
| **Sonarr** | TV series automation & episode management |
| **Radarr** | Movie automation & file management |
| **Lidarr** | Music automation & library management |
| **FileFlows** | Automated transcoding & media processing |
| **Jellyfin** | Streaming server (hardware-accelerated) |
| **Seerr** | User request system for media content |
| **Discord Music Bot** | Play Jellyfin music in Discord voice channels |

### 🔐 **Infrastructure**

| Service | Purpose | Quick Start |
|---------|---------|-------------|
| **Nginx Proxy Manager** | Reverse proxy, SSL/TLS, Let's Encrypt automation | `cd src/proxy && docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d` |
| **Vaultwarden** | Self-hosted password manager (Bitwarden-compatible) | `cd src/password-store && docker compose up -d` |

### 📊 **Monitoring & Observability**

| Service | Purpose | Quick Start |
|---------|---------|-------------|
| **Prometheus + Grafana** | System metrics and visualization | `cd src/monitoring && docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d` |

### 🛠️ **Utilities**

| Service | Purpose | Quick Start |
|---------|---------|-------------|
| **Speedtest** | Internet speed monitoring | `cd src/speedtest && docker compose up -d` |
| **Auto-Update** | Auto-update running containers | `cd src/auto-update && docker compose up -d` |

---

## Storage Strategies

All services support **three flexible storage options**. Choose based on your needs:

### ✅ **Option 1: Named Volumes with Custom Path** (Recommended)

Best for: Production, NAS integration, easy migration

```bash
cd src/media
docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d
```

**Setup** (`.env` file):
```env
# Store all data on external drive, NAS, or cloud mount
HOST_VOLUMES_DIR=/mnt/big-ssd/docker-volumes
# Or: /mnt/nas/docker-volumes, /mnt/usb-drive, etc.
```

**Benefits**:
- ✅ Single environment variable controls all services
- ✅ Data stored on your chosen device (external SSD, NAS, etc.)
- ✅ Portable: copy directory to new host, change variable, done
- ✅ Works with any mount point (USB, NAS, cloud sync)

**Default structure** (if `HOST_VOLUMES_DIR` not set):
```
./docker-volumes/
├── media/
│   ├── config/
│   │   ├── wireguard/
│   │   ├── qbittorrent/
│   │   └── ...
│   └── data/
│       └── [shared media files]
└── proxy/
    └── nginx-proxy-manager/
        ├── data/
        └── letsencrypt/
```

### 📌 **Option 2: Bind Mounts** (Advanced)

Best for: Per-service path control, local development

```bash
cd src/media
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
```

**Setup** (`.env` file):
```env
# Individual paths for each service
HOST_WIREGUARD_CONFIG=./wireguard/config
HOST_QBITTORRENT_CONFIG=./qbittorrent/config
HOST_MEDIA_DATA=/mnt/big-ssd/media
# ... etc
```

**Benefits**:
- Advanced users with complex storage arrangements
- Direct path control (not abstracted through Docker volumes)

### ⚠️ **Option 3: Docker-Managed Volumes** (Testing Only)

Best for: Quick testing, temporary setups

```bash
cd src/media
docker compose up -d
# Data stored in /var/lib/docker/volumes/ (system drive)
```

**Limitations**:
- ❌ Data lost if system drive fills up
- ❌ Migration requires manual export/import
- ⚠️ Not suitable for production or large media libraries

### Comparison Table

| Factor | Named Volumes ✅ | Bind Mounts | Docker Volumes ⚠️ |
|--------|-----------------|------------|-----------------|
| **Setup Time** | Fast | Long | Instant |
| **Storage Control** | Single var | Per-service | None |
| **Portability** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐ |
| **NAS Support** | ✅ | ✅ | ❌ |
| **Recommended** | **Yes** | Advanced only | Testing only |

---

## Reverse Proxy: Secure Remote Access

Access your home lab services remotely with automatic HTTPS and Let's Encrypt certificates.

### Setup

1. **Start Nginx Proxy Manager**:
   ```bash
   cd src/proxy
   docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d
   ```

2. **Access the admin panel**: http://localhost:81
   ```
   Default credentials:
   Email: admin@example.com
   Password: changeme  ← CHANGE immediately!
   ```

3. **Add a proxy host** (example: Jellyfin):
   - Domain name: `jellyfin.yourdomain.com`
   - Forward hostname: `jellyfin` (container name)
   - Forward port: `8096`
   - Enable SSL → Let's Encrypt (auto-renewed)

4. **Point your domain** (`yourdomain.com`) to your home IP:
   - Use **Dynamic DNS** if your ISP changes your IP
   - Update A records to point to your current home IP

5. **Access remotely**:
   ```
   https://jellyfin.yourdomain.com
   ```

**See** [src/proxy/README.md](src/proxy/README.md) for advanced configuration, SSL pinning, and access control.

---

## Configuration & Secrets

### `.env` File (Local Overrides, Git-Ignored)

Each service directory supports `.env` for local customization:

```bash
# Create .env in service directory (e.g., src/media/.env)
# Copy from .env.example as template

# Example: src/media/.env
HOST_VOLUMES_DIR=/mnt/big-ssd/docker-volumes
WIREGUARD_KEY=your_vpn_key_here
JELLYFIN_API_KEY=your_api_key_here
```

### `.env.example` (Template, Git-Tracked)

All default values and secret templates:
- Shows all available options
- Documents variable purposes
- Safe to commit (no actual secrets)

---

## Common Commands

### Service Management

```bash
# Enter service directory
cd src/media

# Start services (with named volumes strategy)
docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d

# View running services
docker compose ps

# View logs (live)
docker compose logs -f

# Stop services
docker compose down

# Restart a specific service
docker compose restart jellyfin

# Remove volumes (⚠️ deletes data!)
docker compose down -v
```

### Monitoring & Debugging

```bash
# View system resource usage
docker stats

# Inspect a volume
docker volume ls
docker volume inspect media_data

# Check docker service logs
journalctl -u docker -f

# Verify network connectivity between containers
docker exec jellyfin ping prowlarr
```

### Backup & Migration

```bash
# Backup a named volume
docker run --rm \
  -v media_config:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/media_config.tar.gz -C /data .

# Restore from backup
docker run --rm \
  -v media_config:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/media_config.tar.gz -C /data

# List all volumes
docker volume ls --filter name=media

# Prune unused volumes (⚠️ careful!)
docker volume prune
```

### Networking

```bash
# Inspect network
docker network ls
docker network inspect proxiable

# Test DNS resolution
docker exec jellyfin getent hosts prowlarr

# Check service connectivity
docker exec jellyfin curl -s http://sonarr:8989/api/health
```

---

## Community & Support

### Resources

- **Docker Documentation**: https://docs.docker.com
- **Docker Compose**: https://docs.docker.com/compose/
- **Jellyfin Wiki**: https://docs.jellyfin.org
- **Community Forums**: Reddit `/r/jellyfin`, `/r/homelab`, Discord servers

### Getting Help

1. **Check service README**: [src/{service}/README.md](./src)
2. **Review logs**: `docker compose logs -f`
3. **Search existing issues**: GitHub Issues

---

**Built with ❤️ for the home lab community**
