# Monitoring Stack (Prometheus + Grafana + Exporters)

A comprehensive monitoring stack for observing system and container metrics.

## Components

-   **Grafana**: Metrics visualization and dashboard creation
-   **Prometheus**: Time-series metrics collection and storage
-   **Node Exporter**: System metrics export from the host
-   **cAdvisor**: Docker container metrics collection

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

## Ports

-   **Grafana**: http://localhost:3000 (hidden by default, uncomment in docker-compose.yml)
-   **Prometheus**: http://localhost:9090 (hidden by default, uncomment in docker-compose.yml)
-   **Node Exporter**: :9100 (internal network)
-   **cAdvisor**: :8080 (internal network)

## Configuration

### Environment Variables

All configuration is in `.env`:

-   **`HOST_VOLUMES_DIR`**: Base directory for named volumes with custom path (optional)
    -   Only needed if using `docker-compose.volumes.yml` override
    -   Default: `./docker-volumes` (relative to docker-compose file)
    -   Examples: `./docker-volumes`, `/mnt/nas/docker-volumes`, `/mnt/external-drive/docker-volumes`

-   **`HOST_GRAFANA_DATA`**: Path for Grafana bind-mount storage (optional)
    -   Only needed if using `docker-compose.bind.yml` override
    -   Default: `./docker-volumes/monitoring/grafana`
    -   Examples: `/mnt/nas/grafana`, `/mnt/external-drive/grafana`

-   **`HOST_PROMETHEUS_DATA`**: Path for Prometheus bind-mount storage (optional)
    -   Only needed if using `docker-compose.bind.yml` override
    -   Default: `./docker-volumes/monitoring/prometheus`
    -   Examples: `/mnt/nas/prometheus`, `/mnt/external-drive/prometheus`

-   **`GF_SECURITY_ADMIN_USER`**: Grafana admin username (default: `admin`)
-   **`GF_SECURITY_ADMIN_PASSWORD`**: Grafana admin password (default: `admin`, should be changed!)
-   **`GF_INSTANCE_NAME`**: Grafana instance name (default: `Home Lab Monitoring`)

See `.env.example` for all available options.

### Data Storage

**Default: Named Volume**:

```bash
docker compose up -d
```

Data is stored in named volumes `grafana-data` and `prometheus-data` (Docker-managed).

**Recommended: Named Volume with Custom Path**:

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

**Advanced: Bind Mount** (for per-service control):

1. **Edit `.env`**:

    ```env
    HOST_GRAFANA_DATA=/mnt/nas/grafana
    HOST_PROMETHEUS_DATA=/mnt/nas/prometheus
    # or for relative paths:
    # HOST_GRAFANA_DATA=./docker-volumes/monitoring/grafana
    # HOST_PROMETHEUS_DATA=./docker-volumes/monitoring/prometheus
    ```

2. **Start with bind-mount override**:
    ```bash
    docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
    ```

## Configuration Files

-   `config/prometheus.yaml`: Prometheus configuration (scrape targets)
-   `config/grafana.ini`: Grafana configuration (domain, auth, etc.)
    -   **⚠️ Important**: Edit `root_url` in the `[server]` section with your domain or IP address:
        ```ini
        root_url = https://your-domain.com/  # or http://your-ip:3000/
        ```
-   `config/provisioning/`: Auto-provisioning of datasources and dashboards

## Network Topology

The stack uses two networks:

-   **metrics** (internal): For communication between monitoring components
-   **proxiable** (external): For access through a reverse proxy (Nginx Proxy Manager, etc.)

All components automatically discover each other by container name (Docker DNS).

## Running with Logs

```bash
docker compose -f docker-compose.yml logs -f grafana
docker compose -f docker-compose.yml logs -f prometheus
```

## Stopping

```bash
docker compose -f docker-compose.yml down
```

## Backup

Create a backup archive of named volumes:

```bash
docker run --rm -v grafana-data:/data -v $(pwd):/backup alpine tar czf /backup/grafana-data-backup.tar.gz -C /data .
docker run --rm -v prometheus-data:/data -v $(pwd):/backup alpine tar czf /backup/prometheus-data-backup.tar.gz -C /data .
```

## Reverse Proxy Integration

To access Grafana through Nginx Proxy Manager:

1. Uncomment ports for Grafana in docker-compose.yml
2. Or use Nginx as a reverse proxy with container name: `http://grafana:3000`
3. Ensure Nginx is in the `proxiable` network or connected to it
4. **Important**: Set `root_url` in `config/grafana.ini` to match your reverse proxy domain (e.g., `https://monitoring.example.com/`)
