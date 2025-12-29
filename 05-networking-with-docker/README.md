# 🌐 Networking with Docker

Master Docker networking to enable communication between containers and the outside world.

- [🌐 Networking with Docker](#-networking-with-docker)
  - [Docker Networking Basics](#docker-networking-basics)
    - [Network Types Overview](#network-types-overview)
    - [Listing Networks](#listing-networks)
    - [Default Networks](#default-networks)
  - [Bridge Networks](#bridge-networks)
    - [How Bridge Networks Work](#how-bridge-networks-work)
    - [Using the Default Bridge](#using-the-default-bridge)
    - [Limitations of Default Bridge](#limitations-of-default-bridge)
  - [Host and None Networks](#host-and-none-networks)
    - [Host Network](#host-network)
    - [None Network](#none-network)
  - [Custom Networks](#custom-networks)
    - [Creating Custom Networks](#creating-custom-networks)
    - [Using Custom Networks](#using-custom-networks)
    - [Connecting Containers to Multiple Networks](#connecting-containers-to-multiple-networks)
    - [Removing Networks](#removing-networks)
  - [Linking Containers](#linking-containers)
    - [Legacy Linking (Not Recommended)](#legacy-linking-not-recommended)
    - [Modern Approach: Custom Networks](#modern-approach-custom-networks)
  - [Port Mapping](#port-mapping)
    - [How Port Mapping Works](#how-port-mapping-works)
    - [Port Mapping Options](#port-mapping-options)
    - [Viewing Port Mappings](#viewing-port-mappings)
    - [Example: Multiple Services](#example-multiple-services)
  - [DNS in Docker](#dns-in-docker)
    - [Built-in DNS Server](#built-in-dns-server)
    - [DNS Resolution in Action](#dns-resolution-in-action)
    - [Custom DNS Settings](#custom-dns-settings)
    - [Network Aliases](#network-aliases)
  - [Exercises](#exercises)
    - [🎯 Exercise 1: Network Exploration](#-exercise-1-network-exploration)
    - [🎯 Exercise 2: Custom Network Communication](#-exercise-2-custom-network-communication)
    - [🎯 Exercise 3: Port Mapping Practice](#-exercise-3-port-mapping-practice)
    - [🎯 Exercise 4: Microservices Networking](#-exercise-4-microservices-networking)
    - [🎯 Exercise 5: Host Network Mode](#-exercise-5-host-network-mode)
  - [📁 Examples Directory](#-examples-directory)
  - [📝 Quick Reference](#-quick-reference)
  - [✅ Checklist](#-checklist)

## Docker Networking Basics

### Network Types Overview

Docker provides several network drivers:

```text
┌─────────────────────────────────────────────────────────────────┐
│                     Docker Network Types                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
│  │  Bridge  │  │   Host   │  │   None   │  │     Overlay      │ │
│  │(default) │  │          │  │          │  │ (Swarm/K8s)      │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘ │
│       │             │             │                 │           │
│  Container     Container    No network         Multi-host       │
│  isolation     shares       interface          networking       │
│  + NAT         host stack                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

| Driver    | Use Case                                 |
| --------- | ---------------------------------------- |
| `bridge`  | Default. Isolated network on single host |
| `host`    | Container uses host's network directly   |
| `none`    | No networking                            |
| `overlay` | Multi-host networking (Docker Swarm)     |
| `macvlan` | Assign MAC address to container          |

### Listing Networks

```bash
# List all networks
docker network ls

# Inspect a network
docker network inspect bridge

# See which containers are on a network
docker network inspect bridge --format='{{json .Containers}}' | jq
```

### Default Networks

```bash
# Docker creates these by default:
docker network ls

# NETWORK ID     NAME      DRIVER    SCOPE
# xxxxxxxxxxxx   bridge    bridge    local
# xxxxxxxxxxxx   host      host      local
# xxxxxxxxxxxx   none      null      local
```

## Bridge Networks

### How Bridge Networks Work

```text
┌─────────────────────────────────────────────────────────────┐
│                        Host Machine                         │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                    docker0 bridge                      │ │
│  │                    (172.17.0.1)                        │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │ │
│  │  │  Container 1 │  │  Container 2 │  │  Container 3 │  │ │
│  │  │  172.17.0.2  │  │  172.17.0.3  │  │  172.17.0.4  │  │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │ │
│  └────────────────────────────────────────────────────────┘ │
│                              │                              │
│                              │ NAT                          │
│                              ▼                              │
│                        eth0 (Host)                          │
│                        (192.168.1.x)                        │
└─────────────────────────────────────────────────────────────┘
```

### Using the Default Bridge

```bash
# Run container on default bridge (automatic)
docker run -d --name web1 nginx:alpine
docker run -d --name web2 nginx:alpine

# Check their IPs
docker inspect web1 --format='{{.NetworkSettings.IPAddress}}'
docker inspect web2 --format='{{.NetworkSettings.IPAddress}}'

# Containers can reach each other by IP
docker exec web1 ping -c 2 172.17.0.3

# But NOT by name on default bridge!
docker exec web1 ping -c 2 web2  # This fails!

# Cleanup
docker rm -f web1 web2
```

### Limitations of Default Bridge

- No automatic DNS resolution between containers
- All containers share the same bridge
- Less isolated than custom networks
- Requires linking or IP addresses for communication

## Host and None Networks

### Host Network

The container shares the host's network namespace.

```bash
# Run with host network
docker run -d --name nginx-host --network host nginx:alpine

# No port mapping needed - container uses host ports directly
curl http://localhost:80

# Check - no IP assigned (uses host's)
docker inspect nginx-host --format='{{.NetworkSettings.IPAddress}}'

# Cleanup
docker rm -f nginx-host
```

**Host network pros:**

- Best performance (no NAT overhead)
- Container accessible on host ports directly

**Host network cons:**

- No network isolation
- Port conflicts with host
- Security concerns

### None Network

Container has no network connectivity.

```bash
# Run with no network
docker run -d --name isolated --network none alpine sleep 3600

# Container has no network interface (except loopback)
docker exec isolated ip addr

# Cannot reach anything
docker exec isolated ping -c 2 8.8.8.8  # Fails

# Cleanup
docker rm -f isolated
```

**Use cases for none network:**

- Maximum isolation
- Batch processing without network
- Security-sensitive workloads

## Custom Networks

Custom user-defined bridge networks provide:

- Automatic DNS resolution between containers
- Better isolation
- More control

### Creating Custom Networks

```bash
# Create a custom bridge network
docker network create my-network

# Create with specific subnet
docker network create \
    --driver bridge \
    --subnet 192.168.100.0/24 \
    --gateway 192.168.100.1 \
    my-custom-network

# Create with IP range
docker network create \
    --driver bridge \
    --subnet 10.10.0.0/16 \
    --ip-range 10.10.1.0/24 \
    --gateway 10.10.0.1 \
    specific-network

# List networks
docker network ls
```

### Using Custom Networks

```bash
# Create network
docker network create app-network

# Run containers on custom network
docker run -d --name db --network app-network redis:alpine
docker run -d --name web --network app-network nginx:alpine

# Containers can reach each other BY NAME!
docker exec web ping -c 2 db  # This works!

# DNS resolution works
docker exec web nslookup db

# Cleanup
docker rm -f web db
docker network rm app-network
```

### Connecting Containers to Multiple Networks

```bash
# Create two networks
docker network create frontend
docker network create backend

# Run a container
docker run -d --name app --network frontend nginx:alpine

# Connect to additional network
docker network connect backend app

# Verify
docker inspect app --format='{{json .NetworkSettings.Networks}}' | jq

# Disconnect from network
docker network disconnect frontend app

# Cleanup
docker rm -f app
docker network rm frontend backend
```

### Removing Networks

```bash
# Remove a specific network
docker network rm my-network

# Remove all unused networks
docker network prune

# Force prune without confirmation
docker network prune -f
```

## Linking Containers

> ⚠️ **Note:** Container linking is a legacy feature. Use custom networks instead.

### Legacy Linking (Not Recommended)

```bash
# Old way - using --link (deprecated)
docker run -d --name redis redis:alpine
docker run -d --name web --link redis:redis nginx:alpine

# The web container can access redis by name
docker exec web ping -c 2 redis
```

### Modern Approach: Custom Networks

```bash
# New way - using custom networks (recommended)
docker network create app-net

docker run -d --name redis --network app-net redis:alpine
docker run -d --name web --network app-net nginx:alpine

# Same result, but more flexible
docker exec web ping -c 2 redis

# Cleanup
docker rm -f redis web
docker network rm app-net
```

## Port Mapping

### How Port Mapping Works

```text
┌─────────────────────────────────────────────────────────────┐
│                         Host                                │
│                                                             │
│    Port 8080 ──────────┐                                    │
│    Port 8081 ──────────┼──────┐                             │
│    Port 3000 ──────────┼──────┼──────┐                      │
│                        │      │      │                      │
│                        ▼      ▼      ▼                      │
│              ┌─────────────────────────────┐                │
│              │     Docker Port Mapping     │                │
│              └─────────────────────────────┘                │
│                        │      │      │                      │
│                        ▼      ▼      ▼                      │
│    ┌───────────┐ ┌───────────┐ ┌───────────┐                │
│    │ Container │ │ Container │ │ Container │                │
│    │  :80      │ │  :80      │ │  :3000    │                │
│    └───────────┘ └───────────┘ └───────────┘                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Port Mapping Options

```bash
# Map host port 8080 to container port 80
docker run -d -p 8080:80 nginx:alpine

# Map to specific host interface
docker run -d -p 127.0.0.1:8080:80 nginx:alpine

# Map to random host port
docker run -d -p 80 nginx:alpine

# Map multiple ports
docker run -d -p 8080:80 -p 8443:443 nginx:alpine

# Map UDP port
docker run -d -p 53:53/udp dns-server

# Map port range
docker run -d -p 8000-8010:8000-8010 my-app

# Publish all exposed ports to random host ports
docker run -d -P nginx:alpine
```

### Viewing Port Mappings

```bash
# See port mappings for a container
docker port my-container

# See specific port
docker port my-container 80

# List containers with ports
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

### Example: Multiple Services

See `examples/multi-service/` directory.

```bash
cd examples/multi-service/
docker-compose up -d

# Access services:
# - Web: http://localhost:8080
# - API: http://localhost:3000
# - Adminer: http://localhost:8081
```

## DNS in Docker

### Built-in DNS Server

Docker runs an embedded DNS server for custom networks.

```text
┌─────────────────────────────────────────────────────────────┐
│                    Custom Network                           │
│                                                             │
│         ┌───────────────────────────────┐                   │
│         │    Docker Embedded DNS        │                   │
│         │        (127.0.0.11)           │                   │
│         └───────────────────────────────┘                   │
│              ▲           ▲           ▲                      │
│              │           │           │                      │
│    ┌─────────┴─┐  ┌──────┴───┐  ┌────┴─────┐                │
│    │    web    │  │   api    │  │    db    │                │
│    │ 10.0.0.2  │  │ 10.0.0.3 │  │ 10.0.0.4 │                │
│    └───────────┘  └──────────┘  └──────────┘                │
│                                                             │
│    web can resolve "api" and "db" by name!                  │
└─────────────────────────────────────────────────────────────┘
```

### DNS Resolution in Action

```bash
# Create network
docker network create dns-demo

# Run containers
docker run -d --name web --network dns-demo nginx:alpine
docker run -d --name api --network dns-demo nginx:alpine
docker run -d --name db --network dns-demo redis:alpine

# Test DNS resolution
docker exec web nslookup api
docker exec web nslookup db

# Ping by name
docker exec web ping -c 2 api
docker exec api ping -c 2 db

# Check DNS server
docker exec web cat /etc/resolv.conf

# Cleanup
docker rm -f web api db
docker network rm dns-demo
```

### Custom DNS Settings

```bash
# Set custom DNS server
docker run -d --dns 8.8.8.8 alpine

# Set DNS search domain
docker run -d --dns-search example.ir alpine

# Set hostname
docker run -d --hostname myhost alpine

# Add hosts entry
docker run -d --add-host myserver:192.168.1.100 alpine
```

### Network Aliases

```bash
# Create network
docker network create alias-demo

# Run container with alias
docker run -d \
    --name mariadb-primary \
    --network alias-demo \
    --network-alias db \
    --network-alias database \
    mariadb:latest \
    -e MARIADB_ROOT_PASSWORD=secret

# Other containers can reach it by any alias
docker run --rm --network alias-demo alpine ping -c 2 db
docker run --rm --network alias-demo alpine ping -c 2 database
docker run --rm --network alias-demo alpine ping -c 2 mariadb-primary

# Cleanup
docker rm -f mariadb-primary
docker network rm alias-demo
```

## Exercises

### 🎯 Exercise 1: Network Exploration

Explore Docker's default networks:

1. List all networks
2. Inspect the bridge network
3. Run containers and check their IPs
4. Test connectivity between containers

<details>
<summary>💡 Solution</summary>

```bash
# List networks
docker network ls

# Inspect bridge network
docker network inspect bridge

# Run two containers
docker run -d --name net-test1 alpine sleep 3600
docker run -d --name net-test2 alpine sleep 3600

# Get their IPs
IP1=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' net-test1)
IP2=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' net-test2)

echo "Container 1 IP: $IP1"
echo "Container 2 IP: $IP2"

# Test connectivity by IP
docker exec net-test1 ping -c 2 $IP2

# Try by name (fails on default bridge)
docker exec net-test1 ping -c 2 net-test2 || echo "Name resolution failed (expected)"

# Cleanup
docker rm -f net-test1 net-test2
```

</details>

### 🎯 Exercise 2: Custom Network Communication

Create a custom network and test DNS:

1. Create a custom bridge network
2. Run multiple containers
3. Test name resolution
4. Connect a container to multiple networks

<details>
<summary>💡 Solution</summary>

```bash
# Create custom network
docker network create --subnet 10.20.0.0/24 my-app-network

# Run containers
docker run -d --name frontend --network my-app-network nginx:alpine
docker run -d --name backend --network my-app-network nginx:alpine
docker run -d --name database --network my-app-network redis:alpine

# Test DNS resolution
docker exec frontend nslookup backend
docker exec frontend nslookup database

# Ping by name
docker exec frontend ping -c 2 backend
docker exec backend ping -c 2 database

# Create another network
docker network create external-network

# Connect backend to both networks
docker network connect external-network backend

# Verify
docker inspect backend --format='{{json .NetworkSettings.Networks}}' | jq

# Run container on external network
docker run -d --name external-service --network external-network alpine sleep 3600

# Backend can reach both networks
docker exec backend ping -c 2 frontend      # my-app-network
docker exec backend ping -c 2 external-service  # external-network

# Cleanup
docker rm -f frontend backend database external-service
docker network rm my-app-network external-network
```

</details>

### 🎯 Exercise 3: Port Mapping Practice

Practice various port mapping scenarios:

<details>
<summary>💡 Solution</summary>

```bash
# Simple port mapping
docker run -d --name web1 -p 8080:80 nginx:alpine

# Map to localhost only
docker run -d --name web2 -p 127.0.0.1:8081:80 nginx:alpine

# Multiple ports
docker run -d --name web3 -p 8082:80 -p 8443:443 nginx:alpine

# Random port
docker run -d --name web4 -p 80 nginx:alpine

# Check mappings
docker port web1
docker port web2
docker port web3
docker port web4

# Test access
curl http://localhost:8080
curl http://localhost:8081
curl http://localhost:8082

# Random port access
RANDOM_PORT=$(docker port web4 80 | cut -d: -f2)
curl http://localhost:$RANDOM_PORT

# Cleanup
docker rm -f web1 web2 web3 web4
```

</details>

### 🎯 Exercise 4: Microservices Networking

Build a complete microservices network:

1. Create frontend and backend networks
2. Run a web server, API, and database
3. Connect API to both networks
4. Test isolation and connectivity

<details>
<summary>💡 Solution</summary>

```bash
# Create networks
docker network create frontend-net
docker network create backend-net

# Run database (backend only)
docker run -d \
    --name db \
    --network backend-net \
    -e MARIADB_ROOT_PASSWORD=secret \
    -e MARIADB_DATABASE=app \
    mariadb:latest

# Run API (connected to both)
docker run -d \
    --name api \
    --network backend-net \
    nginx:alpine

# Connect API to frontend
docker network connect frontend-net api

# Run web frontend
docker run -d \
    --name web \
    --network frontend-net \
    -p 8080:80 \
    nginx:alpine

# Test connectivity
# Web can reach API
docker exec web ping -c 2 api

# Web CANNOT reach db (isolation works!)
docker exec web ping -c 2 db || echo "Cannot reach db (expected - isolation working)"

# API can reach both
docker exec api ping -c 2 web
docker exec api ping -c 2 db

# Cleanup
docker rm -f web api db
docker network rm frontend-net backend-net
```

</details>

### 🎯 Exercise 5: Host Network Mode

Test host network mode:

<details>
<summary>💡 Solution</summary>

```bash
# Run with host network
docker run -d --name nginx-host --network host nginx:alpine

# Access directly on port 80 (no mapping needed)
curl http://localhost:80

# Check no container IP (uses host)
docker inspect nginx-host --format='{{.NetworkSettings.IPAddress}}'

# Compare with bridge mode
docker run -d --name nginx-bridge -p 8080:80 nginx:alpine
docker inspect nginx-bridge --format='{{.NetworkSettings.IPAddress}}'

# Cleanup
docker rm -f nginx-host nginx-bridge
```

</details>

## 📁 Examples Directory

Check the `examples/` directory for complete networking examples:

```text
examples/
├── multi-service/
│   ├── docker-compose.yml
│   └── README.md
└── network-isolation/
    ├── docker-compose.yml
    └── README.md
```

## 📝 Quick Reference

| Command                                       | Description                   |
| --------------------------------------------- | ----------------------------- |
| `docker network ls`                           | List networks                 |
| `docker network create <name>`                | Create a network              |
| `docker network rm <name>`                    | Remove a network              |
| `docker network inspect <name>`               | View network details          |
| `docker network connect <net> <container>`    | Connect container to network  |
| `docker network disconnect <net> <container>` | Disconnect from network       |
| `docker network prune`                        | Remove unused networks        |
| `docker run --network <name>`                 | Run container on network      |
| `docker run -p 8080:80`                       | Map port 8080 to container 80 |
| `docker run --dns 8.8.8.8`                    | Set custom DNS                |
| `docker port <container>`                     | Show port mappings            |

## ✅ Checklist

Before moving to the next section, make sure you can:

- [ ] Explain the different Docker network types
- [ ] Create and manage custom networks
- [ ] Connect containers across networks
- [ ] Use port mapping effectively
- [ ] Understand Docker's DNS resolution
- [ ] Isolate services using multiple networks
- [ ] Debug network connectivity issues

---

⬅️ **Previous:** [Managing Containers](../04-managing-containers/README.md)

➡️ **Next:** [Docker Compose](../06-docker-compose/README.md)
