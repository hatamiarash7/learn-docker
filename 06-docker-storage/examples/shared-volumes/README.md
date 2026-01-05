# Shared Volumes Between Containers

This example shows how multiple containers can share data through a common volume.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Producer     │     │    Consumer     │     │   Web Server    │
│  (writes data)  │     │  (reads data)   │     │ (serves data)   │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         │      read/write       │      read-only        │      read-only
         └───────────┬───────────┴───────────────────────┘
                     │
                     ▼
              ┌─────────────┐
              │   Shared    │
              │   Volume    │
              │ (shared-    │
              │   data)     │
              └─────────────┘
```

## Services

| Service | Role | Volume Access |
|---------|------|---------------|
| producer | Writes messages to log | Read-Write |
| consumer | Reads and displays messages | Read-Only |
| web | Serves log file via HTTP | Read-Only |

## Quick Start

```bash
# Start all services
docker compose up -d

# View producer output
docker compose logs -f producer

# View consumer output
docker compose logs -f consumer

# View log file in browser
open http://localhost:8080/messages.log
```

## Observe Data Sharing

```bash
# Watch all logs together
docker compose logs -f

# You'll see:
# - Producer writing messages every 5 seconds
# - Consumer reading the latest 5 messages
# - Web server is ready at port 8080
```

## Check Volume

```bash
# List volumes
docker volume ls | grep shared

# Inspect volume
docker volume inspect example-shared-data

# View volume contents
docker run --rm -v example-shared-data:/data alpine cat /data/messages.log
```

## Cleanup

```bash
# Stop services
docker compose down

# Stop and remove volume
docker compose down -v
```

## Use Cases

1. **Log Aggregation**: Multiple apps write logs, central service collects
2. **Data Pipelines**: One service produces, another processes
3. **Static Site Generation**: Builder creates files, nginx serves them
4. **Backup Services**: App writes data, backup service reads and archives
