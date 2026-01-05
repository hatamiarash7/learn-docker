# Database Persistence Example

This example demonstrates how to persist database data using Docker volumes.

## Files

- `docker-compose.yml` - Compose file with MariaDB and Adminer
- `init/01-schema.sql` - Database initialization script
- `.env.example` - Environment variables template

## Quick Start

```bash
# Copy environment file
cp .env.example .env

# Start the services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f db
```

## Access

- **Adminer UI**: <http://localhost:8080>
  - Server: `db`
  - Username: `appuser` (or `root`)
  - Password: from `.env` file
  - Database: `myapp`

- **Direct connection**:

  ```bash
  docker compose exec db mariadb -uappuser -papppassword myapp
  ```

## Testing Persistence

```bash
# 1. Add some data
docker compose exec db mariadb -uroot -psecret myapp -e \
    "INSERT INTO users (username, email) VALUES ('newuser', 'new@example.com');"

# 2. Verify data exists
docker compose exec db mariadb -uroot -psecret myapp -e "SELECT * FROM users;"

# 3. Stop and remove containers
docker compose down

# 4. Start again
docker compose up -d

# 5. Verify data persists!
docker compose exec db mariadb -uroot -psecret myapp -e "SELECT * FROM users;"
```

## Cleanup

```bash
# Stop containers only (data preserved)
docker compose down

# Stop containers AND remove volumes (data deleted!)
docker compose down -v
```

## Volume Location

The database data is stored in a Docker-managed volume:

```bash
# Find volume location
docker volume inspect myapp_db-data

# View volume contents (Linux)
sudo ls /var/lib/docker/volumes/myapp_db-data/_data
```
