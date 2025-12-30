# Task 1

## Duration

2–3 hours

## Learning Objectives

By completing this task, you will be able to:

- Build multiple Docker images with metadata
- Use labels for automation instead of names
- Filter containers and images using Docker CLI
- Parse docker inspect output (JSON)
- Automate container management using Bash and Python
- Analyze container state and lifecycle programmatically

## Scenario

You are building containerized internal services.  
All services must be discoverable and manageable using scripts only.  
Manual inspection is forbidden unless explicitly allowed.

## Part 1 – Image Design with Metadata

### Image A: log-producer

Purpose: Simulates a noisy service.

Requirements:

- Base image: alpine
- Prints a log line every 3 seconds:

  ```text
  [INFO] producer alive <timestamp>
  ```

- Runs forever

Labels:

```text
app=log-producer
tier=backend
env=training
```

Tags:

```text
log-producer:1.0
log-producer:stable
```

### Image B: cpu-worker

Purpose: Simulates CPU workload.

Requirements:

- Base image: alpine
- Uses a shell loop that burns CPU briefly, then sleeps
- Runs forever

Labels:

```text
app=cpu-worker
tier=worker
env=training
```

### Image C: toolbox

Purpose: Utility/debug image.

Requirements:

- Base image: `python:3.13-slim`
- Default command: `python3`
- Must include a Python script at:

  ```text
  /opt/info.py
  ```

  This script prints container metadata using docker inspect, or extract from cgroup in case of advanced usage. For example, fill this data:

  ```python
  def main():
      print("Container information")
      print("---------------------")

      print(f"\nHostname        : {}")
      print(f"Container ID    : {}")
      print(f"Current time    : {}")

      print("\nOS Environment variables:")
      # Print all available environment variables inside container
    ```

Labels:

```text
app=toolbox
tier=utility
env=training
```

## Part 2 – Controlled Container Deployment

Run the following containers:

| Image        | Count | Naming Pattern |
| ------------ | ----- | -------------- |
| log-producer | 3     | producer-1..3  |
| cpu-worker   | 2     | worker-1..2    |
| toolbox      | 1     | toolbox-1      |

Rules:

- Detached mode only
- Wait 10–20 seconds between container starts
- Do not use `--rm`

## Part 3 – Advanced docker ps Filtering

Solve all tasks using docker ps filters and formatting only.

Tasks:

1. Show containers with label `tier=worker`
2. Show containers started in the last 2 minutes
3. Output format:

   ```text
   NAME | IMAGE | STATUS
   ```

4. Show only container IDs of log-producer containers
5. Show containers whose name matches `producer-*`

Notes:

- grep is allowed
- docker inspect is **not allowed** in this part

## Part 4 – Bash Automation with docker inspect

### Task 1: Container Metadata Report

Write a Bash script that:

1. Finds all running containers
2. Uses docker inspect
3. Outputs:

   ```text
   CONTAINER_NAME | IMAGE | app | tier | start_time
   ```

Rules:

- Must use `docker inspect --format` or `jq`
- Hardcoded container names are forbidden

### Task 2: Policy Enforcement Script

Write a Bash script that:

- Finds containers where:

  ```text
  env != training
  ```

- Prints their names
- Stops them automatically

### Task 3: Resource Usage Summary

Write a script that:

1. Lists all running containers with their resource usage
2. Outputs:

   ```text
   NAME | CPU% | MEM%
   ```

## Part 5 – Python Automation

### Task 1: Container Age Analyzer

Write a Python script that:

1. Lists all running containers
2. Uses docker inspect via subprocess
3. Calculates container age:

   ```text
   current_time - StartedAt
   ```

4. Outputs:

   ```text
   NAME | AGE_SECONDS | IMAGE | tier
   ```

5. Sorts results by oldest container first

### Task 2: Image Usage Detector

Write a Python script that:

1. Lists all Docker images
2. Detects images with no running containers
3. Outputs:

   ```text
   IMAGE:TAG -> UNUSED
   ```

Rules:

- Must combine `docker images`, `docker ps`, and `docker inspect`
- Hardcoded image names are forbidden

## Part 6 – Bonus Challenge

### Smart Worker Controller

Write a script (Bash or Python) that:

- Finds containers with:

  ```text
  app=cpu-worker
  ```

- If container uptime is greater than 5 minutes:
  - Restart the container
- Otherwise:
  - Do nothing

Rules:

- Must rely on `docker inspect` data
- Manual checks are forbidden

## Submission Requirements

You must submit:

- All Dockerfiles
- All Bash or Python scripts
- Sample command outputs
- A short explanation:
  Why labels are better than container names for automation

You can submit your solutions via a Pull Request

1. Create a new directory under `tasks/1/solutions/` named with your name and place all your files there.
2. Open a Pull Request against the main repository.

> [!NOTE]
> You can deliver your solution later if you don't know anything about git yet.
