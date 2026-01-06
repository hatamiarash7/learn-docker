# Docker Task 1: Container Management with Labels

**Author:** Marzieh Sepehr
**Date:** January 2026

---

##  Project Structure
```bash
.
├── cpu-worker
│   ├── Dockerfile
│   ├── README.md
│   └── worker.py
├── log-producer
│   ├── Dockerfile
│   ├── logger.py
│   └── README.md
├── part2
│   ├── deploy-containers.sh
│   └── README.md
├── part3
│   ├── part3-filters.sh
│   └── README.md
├── part4
│   ├── README.md
│   ├── task1-metadata-report.sh
│   ├── task2-policy-enforcement.sh
│   └── task3-resource-usage.sh
├── part5
│   ├── README.md
│   ├── task1-container-age.py
│   └── task2-image-usage.py
├── part6
│   ├── README.md
│   ├── smart-worker-controller.py
│   └── smart-worker-controller.sh
├── README.md
└── toolbox
    ├── Dockerfile
    ├── info.py
    └── README.md

```




## Labels vs Names - Why Labels Work Better

### The Problem with Names

Container names are **single identifiers** that must be globally unique. When managing multiple containers, names become limiting because you can only express one concept (e.g., `worker-1` tells you it's a worker, but which environment? which version? which tier?). Automation based on names relies on fragile pattern matching with grep and awk, making scripts brittle and error-prone. As systems scale to dozens or hundreds of containers, maintaining consistent naming conventions becomes a nightmare, and name collisions force awkward workarounds like `prod-worker-1-old` or `staging-db-backup-temp`.

### The Label Solution

Labels provide **multi-dimensional metadata** where each container can have multiple key-value pairs describing different aspects: `app=cpu-worker`, `tier=worker`, `env=production`, `version=2.0`, `region=us-east`. This enables semantic grouping and flexible querying using Docker's native filter system. Instead of `docker ps | grep worker | grep prod`, you write `docker ps --filter "label=tier=worker" --filter "label=env=production"` - which is clearer, more reliable, and composable.

### Key Advantages

**1. Multiple Classification Dimensions:** Names force you to encode everything in one string (`prod-us-east-worker-v2-abc`), while labels give you independent attributes that can be queried separately.

**2. Native Tooling Support:** Docker CLI, Docker Compose, Swarm, and Kubernetes all have first-class support for label-based filtering and service discovery. No need for text processing.

**3. Policy-Driven Automation:** Labels enable declarative policies - "restart all containers where `app=cpu-worker` and uptime > 5 minutes" becomes a simple filter, not complex bash parsing.

**4. Scalability:** With 100 containers, label-based queries remain simple (`--filter "label=tier=backend"`), while name-based searches become unmanageable regex patterns.

**5. Self-Documenting Infrastructure:** Labels make your infrastructure semantic and readable. `docker ps --filter "label=env=production"` is immediately clear to anyone, while decoding naming conventions requires tribal knowledge.

### Real-World Example

**Name-based approach (brittle):**
```bash
# Finding all production workers in US-East
docker ps | grep "prod" | grep "worker" | grep "us-east"
# What if someone names a container "prod-test"?
# What if the pattern changes?
```

**Label-based approach (robust):**
```bash
# Clear, declarative, reliable
docker ps --filter "label=env=production" \
          --filter "label=tier=worker" \
          --filter "label=region=us-east"
```

In this project, **every automation script relies on labels** to discover and manage containers without hardcoding names. This makes the scripts reusable, maintainable, and scalable - whether you're managing 6 containers or 600.

---



##  Detailed Documentation

Each directory contains its own README with detailed usage instructions:

- [log-producer/README.md](./log-producer/README.md)
- [cpu-worker/README.md](./cpu-worker/README.md)
- [toolbox/README.md](./toolbox/README.md)
- [part2/README.md](./part2/README.md)
- [part3/README.md](./part3/README.md)
- [part4/README.md](./part4/README.md)
- [part5/README.md](./part5/README.md)
- [part6/README.md](./part6/README.md)




