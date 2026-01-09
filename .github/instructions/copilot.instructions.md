# Home Lab Project - Copilot Instructions

## Project Overview

**Goal**: Create a lightweight, easy-to-use home media server and laboratory environment that requires minimal setup and can run out-of-the-box without deep technical knowledge.

**Target Users**:

-   Beginners who want a pre-configured home server
-   Intermediate users who need flexibility to customize storage
-   Advanced users who want to integrate with existing infrastructure (NAS, cloud storage)

## Technology Stack

-   **Container Runtime**: Docker & Docker Compose
-   **Infrastructure**: 100% containerized (no system-wide dependencies)
-   **Configuration**: `.env` files for secrets and local customization (optional, services use defaults)
-   **Version Control**: Git with proper `.gitignore` exclusions

## Docker Compose Conventions

### Environment Files

All services must support running **without** `.env` file by using sensible defaults:

```yaml
services:
    example:
        env_file:
            - path: .env
              required: false  # Always set to false
        environment:
            - SOME_VAR=${SOME_VAR:-default_value}  # Always provide defaults
```

**Benefits**:
- Users can start services immediately without configuration
- `.env.example` documents available options
- Production users can override with `.env` file

### Storage Strategies (Three Options)

Each service supports three volume strategies via compose file overrides:

#### 1. Docker-Managed Named Volumes (Default, Not Recommended for Large Data)

**Use Case**: Testing and small data only. Volumes stored in `/var/lib/docker/volumes/`.

```bash
docker compose -f docker-compose.yml up -d
```

#### 2. Named Volumes with Custom Path (Recommended) ✅

**Use Case**: All production scenarios. Named volumes point to custom storage via `HOST_VOLUMES_DIR`.

**Example `docker-compose.yml`**:

```yaml
services:
    dashboard:
        container_name: dashboard
        image: ghcr.io/homarr-labs/homarr:latest
        restart: unless-stopped
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - appdata:/app/config
        env_file:
            - .env
        networks:
            - proxiable

volumes:
    appdata:  # Just names, no configuration

networks:
    proxiable:
        external: true
```

**Example `docker-compose.volumes.yml` (Override)**:

```yaml
volumes:
    appdata:
        driver: local
        driver_opts:
            type: none
            o: bind
            device: ${HOST_VOLUMES_DIR:-./docker-volumes}/dashboard/appdata
```

**Usage**:

```bash
# .env should contain (optional, defaults to ./docker-volumes):
# HOST_VOLUMES_DIR=/mnt/storage/docker-volumes

docker compose -f docker-compose.yml -f docker-compose.volumes.yml up -d
```

**Benefits**:
- ✅ Data stored on specified path (external drive, NAS, etc.)
- ✅ Named volumes (portable between hosts)
- ✅ Single environment variable to configure
- ✅ Easy migration (change variable, copy directory)

**Default Directory Structure**:

The structure should match bind mount defaults for consistency. Example:

```
$HOST_VOLUMES_DIR/
├── media/                    # Multi-service stacks (many related services)
│   ├── config/
│   │   ├── wireguard/
│   │   ├── qbittorrent/
│   │   └── ...
│   ├── fileflows/
│   └── data/                 # Shared media content
│
└── proxy/                    # Single-service stacks
    └── nginx-proxy-manager/
        ├── data/
        └── letsencrypt/
```

**Naming Conventions**:
- Multi-service stacks (many related services sharing storage): Use subdirectories under `$HOST_VOLUMES_DIR/<stack_name>/` for organization
  - Example: `media/{config, fileflows, data}`
  - Rationale: Reduces clutter, logical grouping of related files
  
- Single-service stacks: Use `$HOST_VOLUMES_DIR/<service_name>/<volume_name>/`
  - Example: `proxy/nginx-proxy-manager/{data, letsencrypt}`
  - Rationale: Clarity and consistency with service naming
- ✅ Easy migration (copy directory, change variable)
- ✅ Defaults to ./docker-volumes if HOST_VOLUMES_DIR not set

#### 3. Direct Bind Mounts (Alternative, Verbose)

**Use Case**: Users who prefer explicit path definitions per service.

**IMPORTANT**: Default paths must be **identical** to docker-compose.volumes.yml. The only difference is the storage method (bind mount vs named volume) and configuration variables (individual vs unified).

**Implementation via `docker-compose.bind.yml` Override**:

```yaml
services:
    dashboard:
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - ${HOST_DASHBOARD_APPDATA:-./docker-volumes/dashboard/appdata}:/app/config
```

**Usage**:

```bash
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
```

**Key principle**: Both `docker-compose.volumes.yml` and `docker-compose.bind.yml` must use the **same default path structure** (e.g., `./docker-volumes/media/config/...`). This ensures:
- Volumes profile uses `HOST_VOLUMES_DIR` (simple, one variable for all)
- Bind profile uses individual variables like `HOST_WIREGUARD_CONFIG`, `HOST_MEDIA_DATA` (advanced, per-service flexibility)
- Switching between storage strategies doesn't require data migration
- Path consistency across all deployment types
- Easy testing: use bind mounts locally, named volumes in production

## File Guidelines

### README.md (Per Service)

Each service folder must contain a `README.md` that briefly describes:

1. **What it does** (1-2 sentences)
2. **Default ports** (if exposed, with http/https protocols)
3. **Key volumes/configuration**
4. **Quick start** (if needed)
5. **Reverse Proxy Integration** (mandatory section)

The **Reverse Proxy Integration** section should explain:

-   How to access the service through Nginx Proxy Manager
-   Internal container name for reverse proxy setup
-   Network requirements for reverse proxy integration

Example:

````markdown
# Homarr Dashboard

A customizable, self-hosted dashboard to monitor and control home lab services.

## Quick Start

```bash
docker compose -f src/dashboard/docker-compose.yml up -d
```

## Ports

-   Web UI: http://localhost:7575 (hidden by default, uncomment in docker-compose.yml to expose)

## Configuration

-   `SECRET_ENCRYPTION_KEY`: Set in `.env` (encryption key for dashboard data)
-   Storage:
    -   Default: Uses `appdata` named volume (Docker-managed)
    -   Advanced: Use `docker-compose.bind.yml` override to store data on NAS or specific path

## Storage Profiles

**Named Volume (Default)**:

```bash
docker compose up -d
```

**Bind Mount** (for custom storage):

```bash
# Edit .env and set HOST_APPDATA, then run:
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
```

## Reverse Proxy Integration

To access the dashboard through Nginx Proxy Manager:

1. Uncomment ports in docker-compose.yml
2. Or use Nginx as a reverse proxy with container name: `http://dashboard:7575`
3. Ensure Nginx is in the `proxiable` network or connected to it
````

### .env.example

Template file committed to git showing all available environment variables:

-   Include descriptions and example values
-   Document both default and bind-mount configurations
-   **Never commit actual secrets** (use placeholders)

Example structure:

```env
# Storage configuration
# Default: Docker-managed named volume
# Bind-mount: Set HOST_APPDATA to override
HOST_APPDATA=./homarr/appdata

# Secrets (generate random values; use OpenSSL, pwgen, etc.)
SECRET_ENCRYPTION_KEY=your_secret_key_here
```

### .env (Local Override)

Git-ignored file for actual secrets and local customization:

-   Copy from `.env.example` and edit locally
-   Never commit (enforced by `.gitignore`)
-   Contains actual encryption keys, NAS credentials, paths, etc.

### .gitignore

Minimum template for each service:

```
.env
.env.local
.env.*.local
homarr/appdata/
```

## Implementation Guidelines for Copilot

When adding new services or modifying existing ones:

### 1. Always Support Both Storage Profiles

-   **Main compose file** (`docker-compose.yml`): Use named volumes
-   **Override file** (`docker-compose.bind.yml`): Provide bind-mount alternative
-   **Never force users** into a single storage strategy

### 2. Environment Variables

-   Use `.env` file loading via `env_file: [.env]` in docker-compose
-   All secrets go in `.env` (git-ignored)
-   All templates go in `.env.example` (git-tracked)
-   Provide meaningful defaults and comments

### 2a. Naming Conventions for Bind Mount Directories

**Environment Variable Names**:

-   Pattern: `HOST_<SERVICE_NAME>_<VOLUME_TYPE>`
-   Examples: `HOST_NGINX_PROXY_MANAGER_DATA`, `HOST_VAULTWARDEN_DATA`, `HOST_DASHBOARD_APPDATA`
-   Use the **full service name**, not abbreviations (e.g., `nginx-proxy-manager`, not `npm`)

**Default Directory Paths**:

-   Pattern: `./SERVICE_NAME/VOLUME_TYPE/`
-   Examples: `./nginx-proxy-manager/data`, `./vaultwarden/data`, `./dashboard/appdata`
-   Directory naming should **match the service folder name** for clarity and consistency
-   Use underscores or hyphens consistently with Docker service names

**Example .env.example**:

```env
# Bind mount paths (optional, leave commented for default named volumes)
HOST_NGINX_PROXY_MANAGER_DATA=./nginx-proxy-manager/data
HOST_NGINX_PROXY_MANAGER_LETSENCRYPT=./nginx-proxy-manager/letsencrypt

# Or with absolute NAS paths:
# HOST_NGINX_PROXY_MANAGER_DATA=/mnt/nas/nginx-proxy-manager/data
# HOST_NGINX_PROXY_MANAGER_LETSENCRYPT=/mnt/nas/nginx-proxy-manager/letsencrypt
```

**Example docker-compose.bind.yml**:

```yaml
services:
    nginx-proxy-manager:
        volumes:
            - ${HOST_NGINX_PROXY_MANAGER_DATA:-./nginx-proxy-manager/data}:/data
            - ${HOST_NGINX_PROXY_MANAGER_LETSENCRYPT:-./nginx-proxy-manager/letsencrypt}:/etc/letsencrypt
```

**Benefits**:

-   Descriptive and self-documenting
-   Directory structure mirrors service organization
-   Easy to identify which volumes belong to which service
-   Prevents naming conflicts across services

### 3. Networking

-   Use `external: true` for shared networks (e.g., `proxiable` for reverse proxy integration)
-   Document which networks a service requires
-   Assume networks may be managed separately or created on-demand

### 4. Restart Policy

-   Default: `restart: unless-stopped` (restart after reboot, but respect manual stops)
-   Adjust only if service has special requirements

### 5. Security

-   **No hardcoded secrets** in docker-compose files
-   All secrets must be in `.env` / `.env.example`
-   Document how to generate/obtain required secrets (e.g., OpenSSL for encryption keys)

### 6. Documentation

Every modification must include:

-   Updated `README.md` if service behavior changes
-   Updated `.env.example` if new variables are needed
-   Clear comments in docker-compose files for non-obvious configuration

## Common Commands

```bash
# Start with default named volumes
cd src/dashboard
docker compose up -d

# Start with bind-mount storage
cd src/dashboard
HOST_APPDATA=/mnt/nas/media docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d

# View logs
docker compose logs -f dashboard

# Stop service
docker compose down

# List volumes and inspect
docker volume ls
docker volume inspect appdata

# Backup named volume to tar
docker run --rm -v appdata:/data -v $(pwd):/backup alpine tar czf /backup/appdata-backup.tar.gz -C /data .
```

## Design Principles

1. **Zero-Config Default**: Services should start with `docker compose up -d` with minimal prior setup
2. **Progressive Disclosure**: Advanced options (NAS, custom paths) are available but optional
3. **Transparency**: All configuration must be visible and editable (no obscured magic)
4. **Portability**: Data and configuration must be movable across systems
5. **Git-Friendly**: All template files in git, all secrets excluded
6. **Minimal Dependencies**: Each service is self-contained; shared only via Docker networks

## Future Considerations

-   **Central docker-compose.yml**: Root-level orchestration file to start all services at once
-   **Backup/Migration Scripts**: Automated tooling for volume export/import
-   **Monitoring**: Add services for system monitoring and alerting
-   **Documentation**: User-facing guides for common tasks (adding services, backing up, migrating to NAS)
