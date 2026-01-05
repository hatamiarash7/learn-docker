# Web + Database Example

A common web application setup with Nginx, Adminer (database admin), and MariaDB.

## Architecture

```text
┌─────────────────────────────────────────────────────┐
│                       Host                          │
│                                                     │
│   :8080 ──► Nginx (Web Server)                      │
│   :8081 ──► Adminer (Database Admin UI)             │
│                                                     │
│   ┌─────────────────────────────────────────────┐   │
│   │               Internal Network              │   │
│   │                                             │   │
│   │   [nginx]  [adminer]  [mariadb]             │   │
│   │                          │                  │   │
│   │                     [db-data]               │   │
│   └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

## Setup

1. Copy environment file:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your settings

3. Start the application:

   ```bash
   docker-compose up -d
   ```

## Access

- **Web Server:** <http://localhost:8080>
- **Adminer:** <http://localhost:8081>
  - Server: `db`
  - Username: from `.env`
  - Password: from `.env`
  - Database: from `.env`

## Data Persistence

Database data is stored in the `db-data` Docker volume. Data persists across container restarts.

To completely reset:

```bash
docker-compose down -v
```

## Cleanup

```bash
docker-compose down
```
