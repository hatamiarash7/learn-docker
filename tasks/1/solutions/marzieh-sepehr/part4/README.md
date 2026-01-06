# Part 4 - Bash Automation with docker inspect

## Description
Bash scripts for automated container management using `docker inspect` and `docker stats`.

## Tasks

### Task 1: Container Metadata Report

**File:** `task1-metadata-report.sh`
 

**Usage:**
```bash
chmod +x task1-metadata-report.sh
./task1-metadata-report.sh
```

**Output:**
```
./task1-metadata-report.sh       
=======================================
  Container Metadata Report
========================================

CONTAINER_NAME       | IMAGE                     | app             | tier       | start_time
---------------------+---------------------------+-----------------+------------+--------------------
toolbox-1            | toolbox:latest            | toolbox         | utility    | 2026-01-04 18:52:23
worker-2             | cpu-worker:latest         | cpu-worker      | worker     | 2026-01-04 18:52:07
worker-1             | cpu-worker:latest         | cpu-worker      | worker     | 2026-01-04 18:51:52
producer-3           | log-producer:1.0          | log-producer    | backend    | 2026-01-04 18:51:37
producer-2           | log-producer:1.0          | log-producer    | backend    | 2026-01-04 18:51:21
producer-1           | log-producer:1.0          | log-producer    | backend    | 2026-01-04 18:51:06

Report completed!



 

### Task 2: Policy Enforcement Script

 

**Usage:**
```bash
chmod +x task2-policy-enforcement.sh
./task2-policy-enforcement.sh
```

** Output:**
```
========================================
  Policy Enforcement Script
========================================

Checking for containers with env != training...

========================================
No policy violations found. All containers are compliant.
========================================
```

**Test:**
```bash
# Create a test container with different env label
docker run -d --name test-prod --label env=production alpine sleep 3600

# Run the policy script
./task2-policy-enforcement.sh
```

### output:
```bash
========================================
  Policy Enforcement Script
========================================

Checking for containers with env != training...

[VIOLATION] Container: test-prod (env=production)
  Stopping container...
  ✓ Container stopped successfully

========================================
Total violations found and stopped: 1
========================================
```

# Verify it was stopped
docker ps -a | grep test-prod
```

---

### Task 3 
```bash
chmod +x task3-resource-usage.sh
./task3-resource-usage.sh
```

** Output:**
```
========================================
  Resource Usage Summary
========================================

NAME                 | CPU%       | MEM%
---------------------+------------+-----------
toolbox-1            | 0.00%      | 0.01%
worker-2             | 73.35%     | 0.02%
worker-1             | 46.05%     | 0.02%
producer-3           | 0.00%      | 0.04%
producer-2           | 0.04%      | 0.04%
producer-1           | 0.00%      | 0.08%

Resource usage summary completed!
```
 

 