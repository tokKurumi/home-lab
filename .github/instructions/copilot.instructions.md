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
-   **Configuration**: `.env` files for secrets and local customization
-   **Version Control**: Git with proper `.gitignore` exclusions

## Docker Compose Conventions

### 1. Default Profile: Named Volumes (For All Users)

**Use Case**: Default setup that works immediately after cloning the repo.

-   Docker automatically creates and manages named volumes
-   Data persists across container restarts and system reboots
-   Easy to backup/migrate with Docker CLI commands
-   No filesystem paths to configure

**Example `docker-compose.yml`**:

```yaml
services:
    dashboard:
        container_name: dashboard
        image: ghcr.io/homarr-labs/homarr:latest
        restart: unless-stopped
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - appdata:/appdata # Named volume (not a path)
        env_file:
            - .env
        networks:
            - proxiable

volumes:
    appdata: # Docker creates this automatically

networks:
    proxiable:
        external: true # Assumes network exists or will be created
```

**Startup**:

```bash
docker compose -f src/dashboard/docker-compose.yml up -d
```

### 2. Advanced Profile: Bind Mounts (For Power Users)

**Use Case**: Users who need data on specific storage (NAS, external drive, specific partition).

-   Store container data in user-specified directories
-   Full control over storage location and lifecycle
-   Integration with network mounts (NFS, CIFS/SMB)
-   Ability to back up / move data without Docker commands

**Implementation via `docker-compose.bind.yml` Override**:

The override file contains only the volume redefinition:

```yaml
# docker-compose.bind.yml
services:
    dashboard:
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - ${HOST_APPDATA:-./homarr/appdata}:/appdata
```

The `.env` file provides the variable:

```env
# .env
HOST_APPDATA=./homarr/appdata
# Or for advanced: /mnt/nas/homarr, C:\data\homarr, etc.
```

**Startup with Bind Mount**:

```bash
# Use bind-mount with default path
docker compose -f src/dashboard/docker-compose.yml -f docker-compose.bind.yml up -d

# Use bind-mount with custom NAS path (override via env var)
HOST_APPDATA=/mnt/nas/homarr docker compose -f src/dashboard/docker-compose.yml -f docker-compose.bind.yml up -d
```

## File Guidelines

### README.md (Per Service)

Each service folder must contain a `README.md` that briefly describes:

1. **What it does** (1-2 sentences)
2. **Default ports** (if exposed)
3. **Key volumes/configuration**
4. **Quick start** (if needed)

Example:

````markdown
# Homarr Dashboard

A customizable, self-hosted dashboard to monitor and control home lab services.

## Quick Start

```bash
docker compose -f src/dashboard/docker-compose.yml up -d
```

## Ports

-   Web UI: http://localhost:7575 (uncomment in docker-compose.yml to expose)

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
