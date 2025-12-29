# 🐳 Learn Docker

A comprehensive, hands-on Docker learning course designed for practical classroom use. This repository contains exercises, examples, and projects to help students master Docker from basics to advanced concepts.

---

## 📋 Course Overview

This course covers everything you need to know to work with Docker effectively:

| Section                  | Topics                          |
| ------------------------ | ------------------------------- |
| 1. Starting with Docker  | Installation, first containers  |
| 2. Docker Images         | Pull, push, tag, save/load      |
| 3. Build Your Own Images | Dockerfiles, multi-stage builds |
| 4. Managing Containers   | Lifecycle, logs, resources      |
| 5. Networking            | Bridge, host, custom networks   |
| 6. Docker Compose        | Multi-container applications    |

---

## 🗂️ Course Structure

```text
learn-docker/
├── 01-starting-with-docker/
│   └── README.md                 # Introduction, installation, first container
├── 02-docker-images/
│   └── README.md                 # Images, registries, tagging
├── 03-build-your-own-images/
│   ├── README.md                 # Dockerfile guide
│   └── examples/
│       ├── 01-simple-nginx/      # Basic Nginx example
│       ├── 02-python-app/        # Python Flask app
│       ├── 03-nodejs-app/        # Node.js Express app
│       ├── 04-multistage-go/     # Multi-stage Go build
│       └── 06-cmd-entrypoint/    # CMD vs ENTRYPOINT
├── 04-managing-containers/
│   └── README.md                 # Container lifecycle
├── 05-networking-with-docker/
│   ├── README.md                 # Networking concepts
│   └── examples/
│       └── multi-service/        # Multi-network example
└── 06-docker-compose/
    ├── README.md                 # Docker Compose guide
    └── examples/
        ├── basic-web/            # Simple web server
        ├── web-db/               # Web + database
        ├── full-stack/           # Complete application
        ├── scaling/              # Load balancing
        └── healthcheck/          # Health checks
```

## 🚀 Getting Started

### Prerequisites

- A computer with at least 4GB RAM
- Administrative/sudo access
- Internet connection

### Quick Start

1. **Clone this repository:**

   ```bash
   git clone https://github.com/hatamiarash7/learn-docker.git
   cd learn-docker
   ```

2. **Install Docker:**
   - Follow the instructions in [01-starting-with-docker](./01-starting-with-docker/README.md)

3. **Verify installation:**

   ```bash
   docker --version
   docker run hello-world
   ```

4. **Start learning:**
   - Begin with [Section 1: Starting with Docker](./01-starting-with-docker/README.md)

---

## 📚 Course Content

### [1. Starting with Docker](./01-starting-with-docker/README.md)

- What is Docker and why use it?
- Installing Docker on Linux, macOS, and Windows
- Running your first container
- Basic container commands

### [2. Docker Images](./02-docker-images/README.md)

- Understanding images and layers
- Pulling and pushing images
- Image registries (Docker Hub, private)
- Tagging and versioning strategies
- Saving and loading images for offline use

### [3. Build Your Own Images](./03-build-your-own-images/README.md)

- Dockerfile basics and instructions
- Building images with `docker build`
- Best practices for Dockerfiles
- Multi-stage builds for smaller images
- Multi-architecture builds
- Health checks in Dockerfiles
- Understanding CMD vs ENTRYPOINT

### [4. Managing Containers](./04-managing-containers/README.md)

- Container lifecycle (create, start, stop, remove)
- Executing commands in containers
- Viewing and managing logs
- Resource limits (CPU, memory)
- Container inspection and debugging

### [5. Networking with Docker](./05-networking-with-docker/README.md)

- Docker networking fundamentals
- Bridge, host, and none networks
- Creating custom networks
- Container DNS and service discovery
- Port mapping strategies
- Network isolation patterns

### [6. Docker Compose](./06-docker-compose/README.md)

- Introduction to Docker Compose
- Writing docker-compose.yml files
- Defining services, networks, and volumes
- Multi-container application patterns
- Scaling services
- Environment variables and secrets
- Health checks and dependencies

## 💡 Learning Tips

1. **Follow in order:** Each section builds on previous knowledge
2. **Type commands yourself:** Don't just copy-paste, understand each command
3. **Experiment:** Try modifying examples and see what happens
4. **Clean up:** Use `docker system prune` to free up disk space
5. **Read error messages:** Docker's error messages are usually helpful

## 🛠️ Useful Commands Cheat Sheet

```bash
# Container Management
docker run <image>              # Run a container
docker ps                       # List running containers
docker ps -a                    # List all containers
docker stop <container>         # Stop a container
docker rm <container>           # Remove a container
docker logs <container>         # View container logs

# Image Management
docker images                   # List images
docker pull <image>             # Download an image
docker build -t <name> .        # Build an image
docker rmi <image>              # Remove an image

# Docker Compose
docker-compose up -d            # Start services
docker-compose down             # Stop services
docker-compose logs -f          # Follow logs
docker-compose ps               # List services

# System
docker system df                # Show disk usage
docker system prune             # Clean up resources
```

## 🎯 Exercises

Each section contains practical exercises marked with 🎯. Solutions are provided in collapsible sections.

**Exercise Format:**

- Clear objectives
- Step-by-step instructions
- Expected outcomes
- Hidden solutions (click to reveal)

---

## 📂 Example Projects

### Basic Examples

- **Simple Nginx** - Static website with Nginx
- **Python Flask** - Web API with Flask
- **Node.js Express** - REST API with Express

### Advanced Examples

- **Multi-stage Go** - Optimized Go application
- **Full Stack** - Nginx + API + Database + Cache
- **Scaling** - Load balanced application
- **Health Checks** - Proper dependency management

## 🤝 Contributing

Contributions are welcome! If you find errors or have suggestions:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy Learning! 🐳**

*Start your Docker journey with [Section 1: Starting with Docker](./01-starting-with-docker/README.md)*
