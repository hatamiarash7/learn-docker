# Secrets Management Demo

Demonstrates secure handling of sensitive data using Docker Swarm secrets.

## How Secrets Work

```
┌────────────────────────────────────────────────┐
│              MANAGER NODE                       │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │         RAFT LOG (Encrypted at rest)      │ │
│  │                                           │ │
│  │   db_root_password   db_password   api_key│ │
│  └───────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
                        │
                        │ TLS encrypted
                        ▼
┌────────────────────────────────────────────────┐
│              WORKER NODE                        │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │  Container (only receives needed secrets) │ │
│  │                                           │ │
│  │  /run/secrets/db_password  ← tmpfs mount  │ │
│  │  /app/secrets/api.key      ← custom path  │ │
│  │                                           │ │
│  │  ⚠️  Never written to disk!               │ │
│  └───────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
```

## Prerequisites

Initialize swarm:

```bash
docker swarm init
```

## Setup Secrets

```bash
# Create secrets from command line
echo "rootpassword123" | docker secret create db_root_password -
echo "apppassword456" | docker secret create db_password -
echo "api-key-xyz-789" | docker secret create api_key -

# Verify secrets were created
docker secret ls
```

## Deploy

```bash
docker stack deploy -c docker-stack.yml secretsdemo
```

## Verify

```bash
# List services
docker stack services secretsdemo

# Check app service logs to see secrets being used
docker service logs secretsdemo_app

# List secrets in a container
CONTAINER=$(docker ps -q -f "name=secretsdemo_app")
docker exec $CONTAINER ls -la /run/secrets/
docker exec $CONTAINER ls -la /app/secrets/
```

## Access Database

Open <http://localhost:8080> (Adminer)

- Server: `db`
- Username: `appuser`
- Password: `apppassword456` (the db_password secret)
- Database: `myapp`

## Security Best Practices

1. **Never use environment variables for secrets**

   ```yaml
   # ❌ Bad - visible in logs, inspect, etc.
   environment:
     - DB_PASSWORD=mysecret
   
   # ✅ Good - stored securely
   secrets:
     - db_password
   environment:
     - DB_PASSWORD_FILE=/run/secrets/db_password
   ```

2. **Use external secrets for production**

   ```yaml
   secrets:
     db_password:
       external: true  # Must be created before deployment
   ```

3. **Set appropriate permissions**

   ```yaml
   secrets:
     - source: ssl_key
       target: /etc/ssl/private/key.pem
       mode: 0400  # Read-only by owner
   ```

## Clean Up

```bash
# Remove stack
docker stack rm secretsdemo

# Remove secrets
docker secret rm db_root_password db_password api_key
```
