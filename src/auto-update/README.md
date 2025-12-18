# Watchtower

Automatic Docker image update service. Monitors containers and pulls the latest images, automatically restarting containers when updates are available.

## Quick Start

```bash
docker compose up -d
```

Watchtower is a stateless service with no persistent storage, so there are no bind-mount options needed.

## Configuration

### Environment Variables

All configuration is in `.env`:

-   **`WATCHTOWER_CLEANUP`**: Clean up unused images after updates (default: `true`)

-   **`WATCHTOWER_POLL_INTERVAL`**: Check for updates interval in seconds

    -   `60`: Check every minute (useful for testing)
    -   `86400`: Check once per day (recommended for production)

-   **`WATCHTOWER_INCLUDE_STOPPED`**: Include stopped containers in update checks (default: `true`)

-   **`WATCHTOWER_REVIVE_STOPPED`**: Restart stopped containers after update (default: `true`)

See `.env.example` for all available options.

## How It Works

Watchtower monitors all Docker containers with the label `com.centurylinklabs.watchtower.enable=true` and:

1. Checks if newer images are available
2. Pulls the new image
3. Stops the old container
4. Starts a new container with the same configuration but the new image
5. Optionally cleans up the old image

### Enabling Updates for a Container

Add the label to your service's `docker-compose.yml`:

```yaml
services:
    my-service:
        image: my-image:latest
        labels:
            - 'com.centurylinklabs.watchtower.enable=true'
```

## Logs

View container logs:

```bash
docker compose logs -f watchtower
```

## Tips

-   **Test Schedule**: Use `WATCHTOWER_POLL_INTERVAL=60` for testing, then switch to `86400` (24 hours) for production
-   **No Downtime**: Set `WATCHTOWER_REVIVE_STOPPED=true` to restart stopped containers after updates
-   **Selective Updates**: Only containers with the watchtower label will be updated
-   **Cleanup**: Enable `WATCHTOWER_CLEANUP=true` to save disk space by removing old images
-   **Notifications**: Configure email/Slack notifications via `WATCHTOWER_NOTIFICATION_URL` for update alerts

## Disable for Specific Containers

Don't add the watchtower label to containers you want to manage manually.

## Advanced

For cron-based scheduling instead of polling, add to `.env`:

```env
WATCHTOWER_SCHEDULE=0 2 * * *
```

Then add `--schedule` to the command in `docker-compose.yml`.
