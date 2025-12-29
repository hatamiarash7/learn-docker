# 🖼️ Docker Images

This section covers everything you need to know about Docker images.

- [🖼️ Docker Images](#️-docker-images)
  - [Understanding Docker Images](#understanding-docker-images)
    - [What is a Docker Image?](#what-is-a-docker-image)
    - [Image Layers](#image-layers)
    - [Exercise: View Image Layers](#exercise-view-image-layers)
  - [Pull, Push, and Inspect Images](#pull-push-and-inspect-images)
    - [Pulling Images](#pulling-images)
    - [Listing Local Images](#listing-local-images)
    - [Inspecting Images](#inspecting-images)
    - [Removing Images](#removing-images)
    - [Pushing Images](#pushing-images)
  - [Image Registries](#image-registries)
    - [What is a Registry?](#what-is-a-registry)
    - [Popular Registries](#popular-registries)
    - [Working with Different Registries](#working-with-different-registries)
  - [Tagging and Versioning](#tagging-and-versioning)
    - [Understanding Tags](#understanding-tags)
    - [Tagging Best Practices](#tagging-best-practices)
    - [Semantic Versioning for Images](#semantic-versioning-for-images)
    - [Exercise: Tagging Practice](#exercise-tagging-practice)
  - [Save and Load Images](#save-and-load-images)
    - [Why Save/Load Images?](#why-saveload-images)
    - [Saving Images](#saving-images)
    - [Loading Images](#loading-images)
    - [Export vs Save](#export-vs-save)
  - [Exercises](#exercises)
    - [🎯 Exercise 1: Image Exploration](#-exercise-1-image-exploration)
    - [🎯 Exercise 2: Image Tagging](#-exercise-2-image-tagging)
    - [🎯 Exercise 3: Save and Load](#-exercise-3-save-and-load)
    - [🎯 Exercise 4: Image Cleanup](#-exercise-4-image-cleanup)
    - [🎯 Exercise 5: Registry Simulation](#-exercise-5-registry-simulation)
  - [📝 Quick Reference](#-quick-reference)
  - [✅ Checklist](#-checklist)

## Understanding Docker Images

### What is a Docker Image?

A Docker image is a **read-only template** containing:

- A minimal operating system (or just the necessary files)
- Application code
- Dependencies and libraries
- Environment variables
- Configuration files

### Image Layers

Docker images are built in **layers**. Each layer represents a set of filesystem changes.

```text
┌─────────────────────────────────┐
│     Layer 5: App Config         │  <- Your changes
├─────────────────────────────────┤
│     Layer 4: App Code           │
├─────────────────────────────────┤
│     Layer 3: Dependencies       │
├─────────────────────────────────┤
│     Layer 2: Package Updates    │
├─────────────────────────────────┤
│     Layer 1: Base OS (Alpine)   │  <- Base image
└─────────────────────────────────┘
```

**Benefits of layers:**

- Shared between images (saves disk space)
- Cached during builds (faster builds)
- Only changed layers need to be transferred

### Exercise: View Image Layers

```bash
# Pull an image
docker pull nginx:alpine

# View the image history (layers)
docker history nginx:alpine

# View detailed layer information
docker inspect nginx:alpine | jq '.[0].RootFS.Layers'
```

## Pull, Push, and Inspect Images

### Pulling Images

```bash
# Pull the latest version
docker pull alpine

# Pull a specific version
docker pull alpine:3.18

# Pull from a specific registry
docker pull docker.io/library/nginx:alpine

# Pull all tags of an image (use with caution)
docker pull -a busybox
```

### Listing Local Images

```bash
# List all images
docker images

# List with specific format
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# List image IDs only
docker images -q

# Show all images including intermediate layers
docker images -a

# Filter images
docker images --filter "dangling=true"
docker images --filter "reference=nginx*"
```

### Inspecting Images

```bash
# Full inspection (JSON output)
docker inspect nginx:alpine

# Get specific information
docker inspect --format='{{.Config.Env}}' nginx:alpine
docker inspect --format='{{.Config.ExposedPorts}}' nginx:alpine
docker inspect --format='{{.Config.Cmd}}' nginx:alpine

# View image history
docker history nginx:alpine
```

### Removing Images

```bash
# Remove a specific image
docker rmi nginx:alpine

# Remove by image ID
docker rmi abc123def456

# Force remove (even if used by containers)
docker rmi -f nginx:alpine

# Remove all unused images
docker image prune

# Remove ALL images (use with caution!)
docker rmi $(docker images -q)
```

### Pushing Images

```bash
# First, log in to a registry
docker login

# Tag your image for the registry
docker tag my-app:latest username/my-app:latest

# Push to Docker Hub
docker push username/my-app:latest
```

## Image Registries

### What is a Registry?

A registry is a storage and distribution system for Docker images.

```text
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Docker Hub    │     │  Private Reg    │     │      GHCR       │
│  (Public/Free)  │     │   (Your Own)    │     │    (GitHub)     │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     Docker Client       │
                    │  docker pull/push       │
                    └─────────────────────────┘
```

### Popular Registries

| Registry   | URL                       | Description               |
| ---------- | ------------------------- | ------------------------- |
| Docker Hub | hub.docker.com            | Default public registry   |
| GHCR       | ghcr.io                   | GitHub Container Registry |
| GCR        | gcr.io                    | Google Container Registry |
| ECR        | *.dkr.ecr.*.amazonaws.com | AWS Container Registry    |
| ACR        | *.azurecr.io              | Azure Container Registry  |

### Working with Different Registries

```bash
# Docker Hub (default)
docker pull nginx
docker pull docker.io/library/nginx

# GitHub Container Registry
docker pull ghcr.io/owner/image:tag

# Google Container Registry
docker pull gcr.io/project-id/image:tag

# Login to different registries
docker login docker.io
docker login ghcr.io
docker login gcr.io
```

## Tagging and Versioning

### Understanding Tags

Tags identify different versions of an image.

```text
nginx:latest        <- "latest" is the tag
nginx:1.25          <- version tag
nginx:1.25-alpine   <- version + variant tag
nginx:alpine        <- variant tag
```

### Tagging Best Practices

```bash
# Tag an existing image
docker tag nginx:latest my-nginx:v1.0

# Multiple tags for the same image
docker tag my-app:latest my-app:v1.0
docker tag my-app:latest my-app:stable

# Tag for a registry
docker tag my-app:latest myregistry.ir/my-app:v1.0
```

### Semantic Versioning for Images

```text
my-app:1.2.3        <- Major.Minor.Patch
my-app:1.2          <- Major.Minor (latest patch)
my-app:1            <- Major (latest minor and patch)
my-app:latest       <- Most recent build
my-app:stable       <- Stable release
my-app:dev          <- Development build
```

### Exercise: Tagging Practice

```bash
# Pull an image
docker pull alpine:3.18

# Create multiple tags
docker tag alpine:3.18 my-alpine:v1
docker tag alpine:3.18 my-alpine:latest
docker tag alpine:3.18 my-alpine:production

# List to see all tags
docker images | grep my-alpine

# Notice they all have the same IMAGE ID!
```

## Save and Load Images

### Why Save/Load Images?

- Transfer images without a registry
- Backup important images
- Air-gapped environments (no internet)
- Share images via USB, email, etc.

### Saving Images

```bash
# Save a single image
docker save nginx:alpine -o nginx-alpine.tar

# Save with gzip compression
docker save nginx:alpine | gzip > nginx-alpine.tar.gz

# Save multiple images
docker save nginx:alpine alpine:latest -o multiple-images.tar

# Check the file size
ls -lh nginx-alpine.tar
```

### Loading Images

```bash
# Load from tar file
docker load -i nginx-alpine.tar

# Load from gzip compressed file
docker load < nginx-alpine.tar.gz
# Or
gunzip -c nginx-alpine.tar.gz | docker load

# Verify the image was loaded
docker images
```

### Export vs Save

| Command         | Input     | Output          | Use Case                    |
| --------------- | --------- | --------------- | --------------------------- |
| `docker save`   | Image     | Tar with layers | Backup/transfer images      |
| `docker export` | Container | Tar (flat)      | Backup container filesystem |
| `docker load`   | Tar       | Image           | Restore saved image         |
| `docker import` | Tar       | Image           | Create image from export    |

```bash
# Export a container's filesystem
docker run -d --name my-container alpine sleep 1000
docker export my-container -o container-fs.tar

# Import as a new image
docker import container-fs.tar my-imported-image:latest

# Clean up
docker rm -f my-container
```

## Exercises

### 🎯 Exercise 1: Image Exploration

Explore and compare different images:

1. Pull `alpine`, `busybox`, and `nginx:alpine`
2. Compare their sizes
3. Inspect each image to find:
   - The default command
   - Exposed ports
   - Environment variables
4. View the layer history of nginx:alpine

<details>
<summary>💡 Solution</summary>

```bash
# Pull images
docker pull alpine:latest
docker pull busybox:latest
docker pull nginx:alpine

# Compare sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "alpine|busybox|nginx"

# Inspect default commands
echo "Alpine CMD:"
docker inspect --format='{{.Config.Cmd}}' alpine
echo "BusyBox CMD:"
docker inspect --format='{{.Config.Cmd}}' busybox
echo "Nginx CMD:"
docker inspect --format='{{.Config.Cmd}}' nginx:alpine

# Nginx exposed ports
docker inspect --format='{{.Config.ExposedPorts}}' nginx:alpine

# Environment variables
docker inspect --format='{{.Config.Env}}' nginx:alpine

# Layer history
docker history nginx:alpine
```

</details>

### 🎯 Exercise 2: Image Tagging

Practice tagging strategies:

1. Pull `redis:alpine`
2. Create the following tags:
   - `my-redis:latest`
   - `my-redis:v7`
   - `my-redis:production`
   - `my-company/redis:v7-alpine`
3. List all your tagged images
4. Remove all the tags you created

<details>
<summary>💡 Solution</summary>

```bash
# Pull the image
docker pull redis:alpine

# Create tags
docker tag redis:alpine my-redis:latest
docker tag redis:alpine my-redis:v7
docker tag redis:alpine my-redis:production
docker tag redis:alpine my-company/redis:v7-alpine

# List tagged images
docker images | grep -E "my-redis|my-company"

# Remove tags
docker rmi my-redis:latest my-redis:v7 my-redis:production my-company/redis:v7-alpine

# Verify removal (original redis:alpine should still exist)
docker images | grep redis
```

</details>

### 🎯 Exercise 3: Save and Load

Practice offline image transfer:

1. Pull `alpine:3.18`
2. Save it to a compressed tar file
3. Remove the image from Docker
4. Load it back from the file
5. Verify the image is restored

<details>
<summary>💡 Solution</summary>

```bash
# Pull the image
docker pull alpine:3.18

# Save with compression
docker save alpine:3.18 | gzip > alpine-3.18.tar.gz

# Check file size
ls -lh alpine-3.18.tar.gz

# Remove the image
docker rmi alpine:3.18

# Verify it's gone
docker images | grep alpine

# Load it back
docker load < alpine-3.18.tar.gz

# Verify restoration
docker images | grep alpine

# Clean up the file
rm alpine-3.18.tar.gz
```

</details>

### 🎯 Exercise 4: Image Cleanup

Practice cleaning up images:

1. List all images on your system
2. Find dangling images (if any)
3. Remove unused images
4. Calculate total space used by images

<details>
<summary>💡 Solution</summary>

```bash
# List all images
docker images -a

# Find dangling images
docker images -f "dangling=true"

# Remove dangling images
docker image prune -f

# Remove all unused images (not just dangling)
docker image prune -a -f

# Calculate space used
docker system df

# Detailed breakdown
docker system df -v
```

</details>

### 🎯 Exercise 5: Registry Simulation

Create a local registry and practice push/pull:

```bash
# Run a local registry
docker run -d -p 5000:5000 --name registry registry:2

# Pull and tag an image for local registry
docker pull alpine:latest
docker tag alpine:latest localhost:5000/my-alpine:v1

# Push to local registry
docker push localhost:5000/my-alpine:v1

# Remove local copies
docker rmi alpine:latest localhost:5000/my-alpine:v1

# Pull from local registry
docker pull localhost:5000/my-alpine:v1

# Verify
docker images | grep my-alpine

# Clean up
docker rm -f registry
```

## 📝 Quick Reference

| Command                           | Description                 |
| --------------------------------- | --------------------------- |
| `docker pull <image>`             | Download an image           |
| `docker push <image>`             | Upload an image to registry |
| `docker images`                   | List local images           |
| `docker inspect <image>`          | View image details          |
| `docker history <image>`          | View image layers           |
| `docker tag <src> <dest>`         | Create a new tag            |
| `docker rmi <image>`              | Remove an image             |
| `docker save <image> -o file.tar` | Export image to tar         |
| `docker load -i file.tar`         | Import image from tar       |
| `docker image prune`              | Remove unused images        |

## ✅ Checklist

Before moving to the next section, make sure you can:

- [ ] Explain what Docker images are and how layers work
- [ ] Pull images from Docker Hub
- [ ] Inspect images and view their properties
- [ ] Tag images with meaningful version numbers
- [ ] Save and load images for offline transfer
- [ ] Work with different image registries
- [ ] Clean up unused images

---

⬅️ **Previous:** [Starting with Docker](../01-starting-with-docker/README.md)

➡️ **Next:** [Build Your Own Images](../03-build-your-own-images/README.md)
