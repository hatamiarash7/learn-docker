# Docker Task 1 - Solution

**Author:** Mahdi Ghadiri Afzal  
**Date:** January 3, 2026

## 📁 Project Structure

```
mahdi_ghadiri_afzal/
├── dockerfiles/
│   ├── Dockerfile.log-producer
│   ├── Dockerfile.cpu-worker
│   └── Dockerfile.toolbox
├── scripts/
│   ├── build_images.sh
│   ├── cleanup.sh
│   ├── part2_deploy.sh
│   ├── part3_filters.sh
│   ├── part4_task1_metadata.sh
│   ├── part4_task2_policy.sh
│   ├── part4_task3_resources.sh
│   ├── part5_task1_age.py
│   ├── part5_task2_unused.py
│   └── part6_worker_controller.sh
├── info.py
├── outputs/
│   └── sample_outputs.txt
└── README.md
```

## 🚀 Quick Start

### Build All Images
```bash
./scripts/build_images.sh
```

### Deploy Containers
```bash
./scripts/part2_deploy.sh
```

### Run Tests
```bash
# Part 3 - Filtering
./scripts/part3_filters.sh

# Part 4 - Bash Automation
./scripts/part4_task1_metadata.sh
./scripts/part4_task2_policy.sh
./scripts/part4_task3_resources.sh

# Part 5 - Python Automation
python3 scripts/part5_task1_age.py
python3 scripts/part5_task2_unused.py

# Part 6 - Worker Controller
./scripts/part6_worker_controller.sh
```

### Cleanup
```bash
./scripts/cleanup.sh
```

## 💡 Why Labels Are Better Than Container Names for Automation

### 1. Decoupling from Naming Conventions

Labels separate logical identity from instance naming. Multiple containers can share the same label, while names must be unique. This allows flexible scaling without script modifications.

**Example:**
```bash
# Labels: Query all workers regardless of naming
docker ps --filter "label=tier=worker"

# Names: Must maintain exact patterns
docker ps | grep "worker-"  # Breaks if naming changes
```

### 2. Multi-Dimensional Metadata

Labels can encode multiple dimensions (app, tier, environment, version, owner), while names are single strings. This enables complex filtering and categorization.

**Example:**
```bash
# Find all backend services in training environment
docker ps --filter "label=tier=backend" --filter "label=env=training"

# With names alone, this type of query is impossible
```

### 3. Script Stability

Label-based queries remain stable even when naming conventions change. Name-based scripts break with typos or pattern changes.

**Example:**
```bash
# Robust: Works regardless of naming convention
for id in $(docker ps --filter "label=app=cpu-worker" -q); do
    docker inspect $id
done

# Brittle: Fails if naming pattern changes
for name in worker-1 worker-2; do  # Hardcoded names!
    docker inspect $name
done
```

### 4. Automation-Friendly

Labels enable declarative automation. Scripts can query "what" they need (by purpose/role), not "where" it is (by specific name).

**Example:**
```bash
# Policy enforcement: Stop all non-production containers
docker ps --filter "label=env!=production" -q | xargs docker stop

# With names: Must manually maintain a list
docker stop dev-app-1 dev-app-2 test-db-1 # Must update when adding containers
```

### 5. Kubernetes Compatibility

Label selectors are the standard in Kubernetes for service discovery, deployments, and orchestration. Learning labels now prepares you for container orchestration platforms where the same automation patterns work across tools.

### 6. Dynamic Discovery

Labels allow runtime discovery of containers without prior knowledge of their names. This is essential for:
- Auto-scaling scenarios
- Service mesh implementations  
- Dynamic load balancing
- Container orchestration

### Real-World Impact in This Task

- **Part 4 Task 2** (Policy Enforcement): Finding containers with `env != training` would be impossible without labels
- **Part 6** (Smart Worker Controller): Would require hardcoded container names instead of dynamic discovery
- **Scaling**: Adding 10 more workers requires zero script changes with labels, but would break name-based scripts

### Conclusion

Labels provide semantic, flexible, and maintainable automation that scales with infrastructure growth. They transform container management from brittle name-based patterns to robust metadata-driven queries. This is why modern container orchestration platforms like Kubernetes, Docker Swarm, and Nomad all rely heavily on label-based selectors.

## 📝 Implementation Notes

### Docker Images
- All images use minimal base images (`alpine:latest` or `python:3.13-slim`)
- Consistent label schema across all images: `app`, `tier`, `env`
- Each image has a specific purpose aligned with task requirements

### Scripts
- Bash scripts use `docker inspect --format` for robust JSON parsing
- Python scripts handle timezone-aware datetime parsing correctly
- All scripts are executable and self-documenting
- Error handling included for production-ready code

### Automation Features
- Worker controller calculates uptime for intelligent restart decisions
- Policy enforcement automatically identifies and stops non-compliant containers
- Age analyzer sorts containers by creation time for operational insights
- Image usage detector helps identify cleanup opportunities

## ✅ Task Completion Checklist

- ✅ **Part 1:** 3 Docker images built with proper labels and metadata
- ✅ **Part 2:** 6 containers deployed with controlled timing (15s delays)
- ✅ **Part 3:** Advanced filtering using native docker ps capabilities
- ✅ **Part 4:** Bash automation with docker inspect (3 complete tasks)
- ✅ **Part 5:** Python automation with subprocess integration (2 complete tasks)
- ✅ **Part 6:** Smart worker controller with uptime-based restart logic (bonus)

All task requirements have been successfully completed and tested!

## 🧪 Testing

All scripts have been tested and produce expected outputs. Sample outputs are documented in `outputs/sample_outputs.txt` for reference and validation.

## 🧹 Cleanup

To remove all containers and images created during this task:

```bash
./scripts/cleanup.sh

# Optional: Remove images
docker rmi log-producer:1.0 log-producer:stable cpu-worker:latest toolbox:latest
```