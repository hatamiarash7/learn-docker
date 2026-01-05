# Production-Ready Swarm Stack

A complete production-like Docker Swarm stack demonstrating best practices.

## Architecture

```
                                ┌─────────────┐
                                │  Internet   │
                                └──────┬──────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    │           INGRESS NETWORK            │
                    │         (Port 80, 443, 3000)        │
                    └──────────────────┬──────────────────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    │                                      │
              ┌─────┴─────┐                         ┌─────┴─────┐
              │   Nginx   │                         │  Grafana  │
              │ (2 replicas)│                         │           │
              └─────┬─────┘                         └───────────┘
                    │                                      │
     ┌──────────────┴──────────────┐                      │
     │       FRONTEND NETWORK       │              MONITORING
     │                              │               NETWORK
     └──────────────┬──────────────┘                      │
                    │                                      │
              ┌─────┴─────┐                         ┌─────┴─────┐
              │    API    │                         │Prometheus │
              │(4 replicas)│                         │           │
              └─────┬─────┘                         └───────────┘
                    │                                      │
     ┌──────────────┴──────────────┐              ┌───────┴───────┐
     │       BACKEND NETWORK        │              │ Node Exporter │
     │        (internal)            │              │   cAdvisor    │
     └──────────────┬──────────────┘              │   (global)    │
                    │                              └───────────────┘
         ┌──────────┴──────────┐
         │                     │
   ┌─────┴─────┐        ┌─────┴─────┐
   │  MariaDB  │        │   Redis   │
   │           │        │           │
   └───────────┘        └───────────┘
```

## Features

- ✅ Multi-tier architecture
- ✅ Overlay networking with isolation
- ✅ Secret management
- ✅ Configuration management
- ✅ Health checks on all services
- ✅ Resource limits and reservations
- ✅ Rolling update configuration
- ✅ Placement constraints
- ✅ Monitoring with Prometheus & Grafana
- ✅ Nginx reverse proxy with rate limiting

## Prerequisites

```bash
# Initialize swarm
docker swarm init

# Add label for database placement (on manager node)
docker node update --label-add db=true $(docker node ls -q -f "role=manager")
```

## Setup Secrets

```bash
# Create all required secrets
echo "rootpassword123" | docker secret create db_root_password -
echo "apppassword456" | docker secret create db_password -
echo "redispassword789" | docker secret create redis_password -
echo "grafanaadmin" | docker secret create grafana_password -

# Verify
docker secret ls
```

## Deploy

```bash
docker stack deploy -c docker-stack.yml production
```

## Verify Deployment

```bash
# List all services
docker stack services production

# List all tasks
docker stack ps production

# Wait for all services to be healthy
watch docker stack services production
```

## Access Points

| Service | URL | Description |
|---------|-----|-------------|
| Web | <http://localhost> | Nginx proxy |
| API | <http://localhost/api/> | Node.js API |
| Grafana | <http://localhost:3000> | Dashboards |
| Prometheus | <http://localhost:9090> | Metrics |

## Monitoring

### Prometheus Targets

Access <http://localhost:9090/targets> to see:

- Node Exporter instances
- cAdvisor instances
- Prometheus self-monitoring

### Grafana Setup

1. Open <http://localhost:3000>
2. Login: admin / grafanaadmin
3. Add Prometheus data source:
   - URL: <http://prometheus:9090>
4. Import dashboards:
   - Node Exporter: ID 1860
   - Docker: ID 893

## Scaling

```bash
# Scale API
docker service scale production_api=8

# Scale Nginx
docker service scale production_nginx=4
```

## Updates

```bash
# Update API image
docker service update --image node:20-alpine production_api

# Update Nginx configuration
docker config rm nginx_config
docker config create nginx_config ./nginx.conf
docker service update --config-rm nginx_config --config-add source=nginx_config,target=/etc/nginx/nginx.conf production_nginx
```

## Maintenance

```bash
# Drain a node for maintenance
docker node update --availability drain <node-name>

# Restore node
docker node update --availability active <node-name>

# View service logs
docker service logs -f production_api
```

## Clean Up

```bash
# Remove stack
docker stack rm production

# Remove secrets
docker secret rm db_root_password db_password redis_password grafana_password

# Remove volumes (careful - data loss!)
docker volume rm production_db-data production_redis-data production_prometheus-data production_grafana-data
```

## Production Checklist

- [ ] Use external secrets management (Vault, AWS Secrets Manager)
- [ ] Configure TLS/HTTPS
- [ ] Set up log aggregation (ELK, Loki)
- [ ] Configure backup strategy
- [ ] Set up alerting rules
- [ ] Use external database for production
- [ ] Configure proper resource limits
- [ ] Set up CI/CD pipeline
- [ ] Document runbooks
