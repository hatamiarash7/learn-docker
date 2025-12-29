# 🐳 Starting with Docker

Welcome to your Docker learning journey! This section will introduce you to Docker fundamentals and get you running your first container.

- [🐳 Starting with Docker](#-starting-with-docker)
  - [Introduction to Docker](#introduction-to-docker)
    - [What is Docker?](#what-is-docker)
    - [Why Use Docker?](#why-use-docker)
    - [Docker Architecture](#docker-architecture)
  - [Installing Docker](#installing-docker)
    - [Linux (Ubuntu/Debian)](#linux-ubuntudebian)
    - [macOS](#macos)
    - [Windows](#windows)
    - [Verify Installation](#verify-installation)
  - [Your First Docker Container](#your-first-docker-container)
    - [Exercise 1: Hello World](#exercise-1-hello-world)
    - [Exercise 2: Running an Alpine Container](#exercise-2-running-an-alpine-container)
    - [Exercise 3: Running Nginx Web Server](#exercise-3-running-nginx-web-server)
    - [Exercise 4: Interactive BusyBox](#exercise-4-interactive-busybox)
  - [Exercises](#exercises)
    - [🎯 Exercise 1: Explore Container Lifecycle](#-exercise-1-explore-container-lifecycle)
    - [🎯 Exercise 2: Run Multiple Containers](#-exercise-2-run-multiple-containers)
    - [🎯 Exercise 3: Container Inspection](#-exercise-3-container-inspection)
    - [🎯 Exercise 4: Environment Variables](#-exercise-4-environment-variables)
  - [📝 Quick Reference](#-quick-reference)
  - [✅ Checklist](#-checklist)

## Introduction to Docker

### What is Docker?

Docker is a platform for developing, shipping, and running applications in **containers**. Containers are lightweight, standalone, and executable packages that include everything needed to run an application:

- Code
- Runtime
- System tools
- Libraries
- Settings

### Why Use Docker?

| Benefit         | Description                               |
| --------------- | ----------------------------------------- |
| **Consistency** | "Works on my machine" problem is solved   |
| **Isolation**   | Applications run in isolated environments |
| **Portability** | Run anywhere Docker is installed          |
| **Efficiency**  | Containers share the host OS kernel       |
| **Scalability** | Easy to scale applications horizontally   |

### Docker Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                        Docker Client                        │
│                    (docker CLI commands)                    │
└─────────────────────────┬───────────────────────────────────┘
                          │ REST API
┌─────────────────────────▼───────────────────────────────────┐
│                       Docker Daemon                         │
│                        (dockerd)                            │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Containers │  │   Images    │  │      Networks       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Installing Docker

### Linux (Ubuntu/Debian)

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add your user to the docker group (to run without sudo)
sudo usermod -aG docker $USER

# Log out and log back in for the group change to take effect
```

### macOS

1. Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)
2. Double-click the `.dmg` file
3. Drag Docker to Applications
4. Open Docker from Applications

### Windows

1. Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)
2. Run the installer
3. Follow the installation wizard
4. Enable WSL 2 when prompted (recommended)

### Verify Installation

```bash
# Check Docker version
docker --version

# Check Docker is running
docker info

# Run a test container
docker run hello-world
```

## Your First Docker Container

### Exercise 1: Hello World

Run the classic hello-world container:

```bash
# Pull and run the hello-world image
docker run hello-world
```

**Expected Output:**

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

### Exercise 2: Running an Alpine Container

Alpine is a minimal Linux distribution (~5MB), perfect for learning.

```bash
# Run Alpine and execute a command
docker run alpine echo "Hello from MCI"

# Run Alpine interactively
docker run -it alpine /bin/sh

# Inside the container, try these commands:
cat /etc/os-release
uname -a
exit
```

### Exercise 3: Running Nginx Web Server

```bash
# Run Nginx in detached mode with port mapping
docker run -d -p 8080:80 --name my-nginx nginx:alpine

# Check if the container is running
docker ps

# Access the web server
curl http://localhost:8080

# Or open in browser: http://localhost:8080

# Stop the container
docker stop my-nginx

# Remove the container
docker rm my-nginx
```

### Exercise 4: Interactive BusyBox

BusyBox combines tiny versions of many common UNIX utilities.

```bash
# Run BusyBox interactively
docker run -it busybox

# Inside the container:
ls /bin
echo "BusyBox has $(ls /bin | wc -l) commands!"
exit
```

## Exercises

### 🎯 Exercise 1: Explore Container Lifecycle

Complete the following tasks:

1. Run an Alpine container that prints "Docker is awesome"
2. Run the container in detached mode
3. Check the container logs
4. Stop and remove the container

<details>
<summary>💡 Solution</summary>

```bash
# Step 1: Run with a message
docker run alpine echo "Docker is awesome"

# Step 2: Run detached with a name
docker run -d --name awesome-alpine alpine sleep 60

# Step 3: Check logs (will be empty for sleep)
docker logs awesome-alpine

# Step 4: Stop and remove
docker stop awesome-alpine
docker rm awesome-alpine

# Or remove in one command
docker rm -f awesome-alpine
```

</details>

### 🎯 Exercise 2: Run Multiple Containers

Run three different containers simultaneously:

1. An Nginx web server on port 8081
2. A Redis server (just running, no port mapping needed)
3. An Alpine container sleeping for 300 seconds

<details>
<summary>💡 Solution</summary>

```bash
# Start all three containers
docker run -d -p 8081:80 --name web nginx:alpine
docker run -d --name cache redis:alpine
docker run -d --name sleeper alpine sleep 300

# Verify all are running
docker ps

# Check Nginx is accessible
curl http://localhost:8081

# Clean up when done
docker stop web cache sleeper
docker rm web cache sleeper
```

</details>

### 🎯 Exercise 3: Container Inspection

1. Run a container
2. Find its IP address
3. Find what command it's running
4. Check its resource usage

<details>
<summary>💡 Solution</summary>

```bash
# Run a container
docker run -d --name inspector nginx:alpine

# Get IP address
docker inspect inspector | grep IPAddress
# Or more specifically:
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' inspector

# Get the command
docker inspect -f '{{.Config.Cmd}}' inspector

# Check resource usage
docker stats inspector --no-stream

# Clean up
docker rm -f inspector
```

</details>

### 🎯 Exercise 4: Environment Variables

Run a container with environment variables:

<details>
<summary>💡 Solution</summary>

```bash
# Run Alpine with environment variables
docker run -e MY_NAME="Student" -e MY_CLASS="Docker 101" alpine env

# You should see your variables in the output
```

</details>

## 📝 Quick Reference

| Command                      | Description                        |
| ---------------------------- | ---------------------------------- |
| `docker run <image>`         | Run a new container                |
| `docker run -d`              | Run in detached mode               |
| `docker run -it`             | Run interactively with TTY         |
| `docker run -p 8080:80`      | Map port 8080 to container port 80 |
| `docker run --name <name>`   | Assign a name to the container     |
| `docker run -e VAR=value`    | Set environment variable           |
| `docker ps`                  | List running containers            |
| `docker ps -a`               | List all containers                |
| `docker stop <container>`    | Stop a container                   |
| `docker rm <container>`      | Remove a container                 |
| `docker logs <container>`    | View container logs                |
| `docker inspect <container>` | View container details             |

## ✅ Checklist

Before moving to the next section, make sure you can:

- [ ] Explain what Docker is and why it's useful
- [ ] Run a basic container
- [ ] Run a container in detached mode
- [ ] Map ports between host and container
- [ ] Use environment variables
- [ ] Stop and remove containers
- [ ] View container logs

---

➡️ **Next Section:** [Docker Images](../02-docker-images/README.md)
