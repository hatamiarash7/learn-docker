# 🏆 Final Project: Production E-Commerce Platform

> **Estimated Time**: 8-12 hours  
> **Prerequisites**: Complete all course sections (1-8)

## 📋 Project Overview

You are the DevOps engineer for **"ShopStream"**, a rapidly growing e-commerce startup. Your task is to design, build, and deploy a complete production-grade microservices platform using Docker Swarm.

The platform must handle:

- User authentication and sessions
- Product catalog with search
- Shopping cart functionality
- Order processing
- Real-time notifications
- Centralized logging
- Full observability (metrics, alerts, dashboards)

**This project tests EVERYTHING you've learned in this course.**

## 🎯 Project Requirements

### Infrastructure Requirements

| Component      | Specification                                |
| -------------- | -------------------------------------------- |
| Swarm Cluster  | 1 Manager + 2 Workers                        |
| Total Services | Minimum 12 services                          |
| Networks       | At least 4 overlay networks                  |
| Volumes        | Persistent storage for all stateful services |
| Secrets        | All sensitive data in Docker secrets         |
| Configs        | External configuration files                 |

### Architecture Requirements

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INTERNET                                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INGRESS NETWORK                                     │
│                                                                             │
│    ┌──────────────┐         ┌──────────────┐         ┌──────────────┐       │
│    │   Traefik    │         │   Traefik    │         │   Traefik    │       │
│    │  (Replica)   │         │  (Replica)   │         │  (Replica)   │       │
│    └──────────────┘         └──────────────┘         └──────────────┘       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
        ▼                           ▼                           ▼
┌───────────────┐           ┌───────────────┐           ┌───────────────┐
│   FRONTEND    │           │   API GATEWAY │           │   WEBSOCKET   │
│   NETWORK     │           │   NETWORK     │           │   NETWORK     │
│               │           │               │           │               │
│  ┌─────────┐  │           │  ┌─────────┐  │           │  ┌─────────┐  │
│  │ Frontend│  │           │  │   API   │  │           │  │  Socket │  │
│  │  (Vue)  │  │           │  │ Gateway │  │           │  │ Server  │  │
│  └─────────┘  │           │  └─────────┘  │           │  └─────────┘  │
└───────────────┘           └───────┬───────┘           └───────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
            ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
            │    Auth     │ │   Product   │ │    Order    │
            │   Service   │ │   Service   │ │   Service   │
            └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
                   │               │               │
┌──────────────────┴───────────────┴───────────────┴──────────────────────────┐
│                           BACKEND NETWORK (internal)                        │
│                                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ MariaDB  │  │  Redis   │  │ Elastic  │  │ RabbitMQ │  │  MinIO   │       │
│  │ (Primary)│  │ (Cluster)│  │  Search  │  │ (Queue)  │  │ (Storage)│       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
┌───────────────────────────────────┴─────────────────────────────────────────┐
│                          MONITORING NETWORK                                 │
│                                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │Prometheus│  │ Grafana  │  │  Loki    │  │ Promtail │  │ Alertmgr │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 📦 Required Services

### Tier 1: Edge Layer

| Service     | Image   | Replicas | Requirements                                   |
| ----------- | ------- | -------- | ---------------------------------------------- |
| **Traefik** | traefik | 3        | Reverse proxy, SSL termination, load balancing |

### Tier 2: Application Layer

| Service                  | Build From            | Replicas | Requirements                                    |
| ------------------------ | --------------------- | -------- | ----------------------------------------------- |
| **Frontend**             | Custom (Vue.js/React) | 3        | Static SPA, Nginx-based                         |
| **API Gateway**          | Custom (Node.js)      | 4        | Rate limiting, auth validation, request routing |
| **Auth Service**         | Custom (Python/Go)    | 2        | JWT tokens, session management                  |
| **Product Service**      | Custom (Node.js)      | 3        | CRUD, search integration                        |
| **Order Service**        | Custom (Python)       | 2        | Order processing, payment mock                  |
| **Notification Service** | Custom (Node.js)      | 2        | WebSocket, email mock                           |

### Tier 3: Data Layer

| Service           | Image         | Replicas | Requirements                        |
| ----------------- | ------------- | -------- | ----------------------------------- |
| **MariaDB**       | mariadb       | 1        | Primary database, persistent volume |
| **Redis**         | redis         | 1        | Sessions, caching, rate limiting    |
| **Elasticsearch** | elasticsearch | 1        | Product search                      |
| **RabbitMQ**      | rabbitmq      | 1        | Message queue                       |
| **MinIO**         | minio/minio   | 1        | Object storage (product images)     |

### Tier 4: Observability Layer

| Service           | Image                    | Replicas | Requirements                  |
| ----------------- | ------------------------ | -------- | ----------------------------- |
| **Prometheus**    | prom/prometheus          | 1        | Metrics collection            |
| **Grafana**       | grafana/grafana          | 1        | Dashboards                    |
| **Loki**          | grafana/loki             | 1        | Log aggregation               |
| **Promtail**      | grafana/promtail         | global   | Log collection from all nodes |
| **Alertmanager**  | prom/alertmanager        | 1        | Alert routing                 |
| **cAdvisor**      | gcr.io/cadvisor/cadvisor | global   | Container metrics             |
| **Node Exporter** | prom/node-exporter       | global   | Host metrics                  |

## 🔧 Technical Specifications

### 1. Custom Images (You Must Build)

You must create Dockerfiles for **at least 6 custom services**. Each Dockerfile must:

- [ ] Use multi-stage builds
- [ ] Include health checks
- [ ] Run as non-root user
- [ ] Have optimized layer caching
- [ ] Include proper labels (maintainer, version, description)
- [ ] Use `.dockerignore` files

**Example structure for each service:**

```text
services/
├── auth-service/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── src/
│   ├── requirements.txt (or package.json)
│   └── healthcheck.sh
├── product-service/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── src/
│   └── package.json
└── ...
```

### 2. Network Isolation

Create isolated networks:

```yaml
networks:
  # Public-facing (Traefik only)
  traefik-public:
    driver: overlay
    
  # Frontend services
  frontend:
    driver: overlay
    
  # API and microservices
  backend:
    driver: overlay
    internal: true  # No external access!
    
  # Database tier
  data:
    driver: overlay
    internal: true
    
  # Monitoring only
  monitoring:
    driver: overlay
```

### 3. Secrets Management

All sensitive data MUST use Docker secrets:

| Secret Name              | Description                    |
| ------------------------ | ------------------------------ |
| `db_root_password`       | MariaDB root password          |
| `db_app_password`        | Application database password  |
| `redis_password`         | Redis authentication           |
| `jwt_secret`             | JWT signing key (min 256 bits) |
| `rabbitmq_password`      | RabbitMQ credentials           |
| `minio_secret_key`       | MinIO secret key               |
| `grafana_admin_password` | Grafana admin password         |
| `elasticsearch_password` | Elasticsearch password         |
| `smtp_password`          | Email service password         |
| `ssl_certificate`        | TLS certificate                |
| `ssl_private_key`        | TLS private key                |

### 4. Configuration Management

Use Docker configs for:

| Config Name           | File                      |
| --------------------- | ------------------------- |
| `traefik_config`      | traefik.yml               |
| `prometheus_config`   | prometheus.yml            |
| `alertmanager_config` | alertmanager.yml          |
| `grafana_datasources` | datasources.yml           |
| `grafana_dashboards`  | dashboards.yml            |
| `loki_config`         | loki.yml                  |
| `nginx_config`        | nginx.conf (for frontend) |

### 5. Volume Persistence

Create named volumes for all stateful services:

```yaml
volumes:
  mariadb-data:
  redis-data:
  elasticsearch-data:
  rabbitmq-data:
  minio-data:
  prometheus-data:
  grafana-data:
  loki-data:
```

### 6. Resource Constraints

Every service MUST have resource limits:

```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 128M
```

### 7. Health Checks

Every service MUST have health checks:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

### 8. Rolling Updates

Configure proper update strategies:

```yaml
deploy:
  update_config:
    parallelism: 1
    delay: 30s
    failure_action: rollback
    monitor: 60s
    max_failure_ratio: 0.1
    order: start-first
  rollback_config:
    parallelism: 1
    delay: 10s
```

### 9. Placement Constraints

Use placement constraints appropriately:

```yaml
deploy:
  placement:
    constraints:
      - node.role == manager  # For Traefik, stateful services
      - node.labels.db == true  # For databases
    preferences:
      - spread: node.id  # Distribute across nodes
```

## 🔨 Automation Scripts

You must create the following automation scripts:

### Directory Structure

```text
scripts/
├── cluster/
│   ├── init-swarm.sh           # Initialize swarm cluster
│   ├── join-workers.sh         # Join worker nodes
│   ├── setup-labels.sh         # Configure node labels
│   └── teardown.sh             # Complete cleanup
│
├── secrets/
│   ├── create-secrets.sh       # Create all secrets
│   ├── rotate-secrets.sh       # Rotate secrets safely
│   └── cleanup-secrets.sh      # Remove all secrets
│
├── deploy/
│   ├── build-images.sh         # Build all custom images
│   ├── push-images.sh          # Push to registry
│   ├── deploy-stack.sh         # Deploy complete stack
│   ├── update-service.sh       # Update single service
│   └── rollback-service.sh     # Rollback single service
│
├── maintenance/
│   ├── backup-volumes.sh       # Backup all volumes
│   ├── restore-volumes.sh      # Restore from backup
│   ├── drain-node.sh           # Drain node for maintenance
│   ├── health-check.sh         # Check all services health
│   └── cleanup-images.sh       # Remove unused images
│
├── monitoring/
│   ├── export-logs.sh          # Export logs for analysis
│   ├── check-metrics.sh        # Query Prometheus metrics
│   └── send-test-alert.sh      # Test alerting pipeline
│
└── testing/
    ├── load-test.sh            # Run load tests
    ├── chaos-test.sh           # Simulate failures
    ├── integration-test.sh     # Run integration tests
    └── smoke-test.sh           # Basic functionality test
```

### Script Requirements

Each script must:

1. Have proper shebang (`#!/bin/bash`)
2. Use `set -euo pipefail` for error handling
3. Include usage/help documentation
4. Accept command-line arguments where appropriate
5. Log all actions with timestamps
6. Return appropriate exit codes
7. Be idempotent (safe to run multiple times)

### Example Script Template

```bash
#!/bin/bash
set -euo pipefail

# ============================================
# Script: deploy-stack.sh
# Description: Deploy the complete ShopStream stack
# Usage: ./deploy-stack.sh [--build] [--force]
# ============================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✓ $1${NC}"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ✗ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠ $1${NC}"
}

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Deploy the ShopStream stack to Docker Swarm.

Options:
    --build     Build images before deploying
    --force     Force recreation of services
    --dry-run   Show what would be done
    -h, --help  Show this help message

Examples:
    $(basename "$0")
    $(basename "$0") --build
    $(basename "$0") --build --force
EOF
}

# Parse arguments
BUILD=false
FORCE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            BUILD=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main logic
main() {
    log "Starting deployment..."
    
    # Pre-flight checks
    if ! docker info &> /dev/null; then
        log_error "Docker is not running"
        exit 1
    fi
    
    if ! docker node ls &> /dev/null; then
        log_error "Not a swarm manager"
        exit 1
    fi
    
    # Your deployment logic here...
    
    log_success "Deployment complete!"
}

main "$@"
```

## 📊 Monitoring Requirements

### Prometheus Configuration

Create alert rules for:

- [ ] Service down (any service has 0 healthy replicas)
- [ ] High CPU usage (>80% for 5 minutes)
- [ ] High memory usage (>85% for 5 minutes)
- [ ] High error rate (>5% of requests failing)
- [ ] High response time (p95 > 2 seconds)
- [ ] Disk space low (<20% free)
- [ ] Certificate expiring soon (<7 days)

### Grafana Dashboards

Create dashboards for:

1. **Cluster Overview**
   - Node status
   - Service health
   - Resource utilization

2. **Application Metrics**
   - Request rate
   - Error rate
   - Response times
   - Active users

3. **Database Metrics**
   - Connections
   - Query performance
   - Replication lag

4. **Business Metrics**
   - Orders per minute
   - Cart abandonment
   - Revenue (mock)

### Logging Requirements

All logs must:

- Be collected by Promtail
- Be stored in Loki
- Be queryable in Grafana
- Include structured fields (JSON)
- Have proper log levels

## 🧪 Testing Requirements

### Load Testing

Use tools like `hey`, `wrk`, or `k6` to:

- [ ] Test 100 concurrent users for 5 minutes
- [ ] Verify auto-scaling behavior
- [ ] Measure response times under load
- [ ] Test graceful degradation

### Chaos Testing

Create chaos scenarios:

- [ ] Kill random containers
- [ ] Drain a worker node
- [ ] Simulate network partition
- [ ] Database failover
- [ ] High latency injection

### Integration Testing

Test all service interactions:

- [ ] User registration → login → browse → add to cart → checkout
- [ ] Product search functionality
- [ ] Real-time notification delivery
- [ ] Order status updates

## 📁 Final Deliverables

Your submission must include:

```text
shopstream/
├── README.md                      # Project documentation
├── ARCHITECTURE.md                # Architecture decisions
├── RUNBOOK.md                     # Operational procedures
│
├── docker-stack.yml               # Main stack file
├── docker-stack.monitoring.yml    # Monitoring stack
├── docker-stack.logging.yml       # Logging stack
│
├── services/                      # Custom service code
│   ├── frontend/
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   ├── nginx.conf
│   │   └── src/
│   ├── api-gateway/
│   ├── auth-service/
│   ├── product-service/
│   ├── order-service/
│   └── notification-service/
│
├── configs/                       # Configuration files
│   ├── traefik/
│   ├── prometheus/
│   ├── grafana/
│   ├── loki/
│   └── alertmanager/
│
├── scripts/                       # Automation scripts
│   ├── cluster/
│   ├── secrets/
│   ├── deploy/
│   ├── maintenance/
│   ├── monitoring/
│   └── testing/
│
├── tests/                         # Test files
│   ├── load/
│   ├── chaos/
│   └── integration/
│
├── docs/                          # Additional documentation
│   ├── API.md
│   ├── TROUBLESHOOTING.md
│   └── diagrams/
│
└── .github/                       # CI/CD (optional bonus)
    └── workflows/
        ├── build.yml
        └── deploy.yml
```

## 🚫 Common Mistakes to Avoid

1. **Hardcoding secrets** in docker-compose files
2. **Missing health checks** causing deployment issues
3. **No resource limits** leading to resource exhaustion
4. **Internal services exposed** to public network
5. **No volume backups** before testing
6. **Ignoring log aggregation** making debugging impossible
7. **Missing update strategies** causing downtime
8. **No monitoring** of critical services
9. **Poor documentation** making handoff difficult
10. **Untested scripts** that fail in production

## 💡 Hints

1. **Start simple**: Get basic services running first, then add complexity
2. **Test incrementally**: Deploy and test each tier before moving on
3. **Use Docker Compose locally**: Test locally before swarm deployment
4. **Check logs early**: `docker service logs` is your friend
5. **Version everything**: Use specific image tags, never `latest`
6. **Document as you go**: Don't leave documentation for last
7. **Backup often**: Before major changes, backup your volumes
8. **Use placement wisely**: Databases on manager, stateless on workers
9. **Monitor from day one**: Set up Prometheus/Grafana early
10. **Test failure scenarios**: Kill services and see what happens

## 🏁 Submission

1. Create a private Git repository
2. Push all your code and configurations
3. Include a demo video (5-10 minutes) showing:
   - Cluster setup
   - Stack deployment
   - Application functionality
   - Monitoring dashboards
   - Failure recovery
   - Script execution
4. Submit repository URL and video link

## ⏰ Timeline Suggestion

| Phase          | Duration | Tasks                                    |
| -------------- | -------- | ---------------------------------------- |
| Planning       | 1 hour   | Review requirements, design architecture |
| Infrastructure | 2 hours  | Set up swarm, networks, secrets          |
| Custom Images  | 3 hours  | Build all Dockerfiles                    |
| Deployment     | 2 hours  | Deploy and debug services                |
| Monitoring     | 2 hours  | Configure observability stack            |
| Scripts        | 2 hours  | Create automation scripts                |
| Testing        | 1 hour   | Run all tests                            |
| Documentation  | 1 hour   | Complete all docs                        |

---

**Good luck! This project simulates real-world production challenges. Take your time, think carefully, and remember: production systems require attention to detail.** 🐳
