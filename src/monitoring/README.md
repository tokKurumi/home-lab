# Monitoring Stack (Prometheus + Grafana + Exporters)

A comprehensive monitoring stack for observing system and container metrics.

## Components

-   **Grafana**: Metrics visualization and dashboard creation
-   **Prometheus**: Time-series metrics collection and storage
-   **Node Exporter**: System metrics export from the host
-   **cAdvisor**: Docker container metrics collection

## Quick Start

```bash
docker compose -f src/monitoring/docker-compose.yml up -d
```

## Ports

-   **Grafana**: http://localhost:3000 (hidden by default, uncomment in docker-compose.yml)
-   **Prometheus**: http://localhost:9090 (hidden by default, uncomment in docker-compose.yml)
-   **Node Exporter**: :9100 (internal network)
-   **cAdvisor**: :8080 (internal network)

## Configuration

### Environment Variables

All variables are set in the `.env` file:

```bash
cp .env.example .env
# Edit .env if needed
```

### Data Storage

**Default (named volumes)**:

```bash
docker compose -f docker-compose.yml up -d
```

Data is stored in named volumes `grafana-data` and `prometheus-data` (Docker-managed).

**Alternative: Bind-mount** (to store data on specific paths, NAS, etc.):

```bash
# Edit .env and set HOST_GRAFANA_DATA and HOST_PROMETHEUS_DATA

# Run with override file:
docker compose -f docker-compose.yml -f docker-compose.bind.yml up -d
```

Example `.env`:

```env
HOST_GRAFANA_DATA=./monitoring/grafana/data
HOST_PROMETHEUS_DATA=./monitoring/prometheus/data

# Or with NAS:
# HOST_GRAFANA_DATA=/mnt/nas/monitoring/grafana/data
# HOST_PROMETHEUS_DATA=/mnt/nas/monitoring/prometheus/data
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
