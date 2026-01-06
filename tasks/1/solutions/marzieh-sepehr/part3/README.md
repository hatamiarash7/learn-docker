### Task 1: Show containers with label `tier=worker`

**Command:**
```bash
docker ps --filter "label=tier=worker" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
```

### Output:
```

NAMES      IMAGE               STATUS
worker-2   cpu-worker:latest   Up 4 minutes
worker-1   cpu-worker:latest   Up 5 minutes
```

---

### Task 2: Show containers started in the last 2 minutes

**Command:**
```bash
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
```

### outpput
```bash
NAMES        IMAGE               STATUS
toolbox-1    toolbox:latest      Up 5 minutes
worker-2     cpu-worker:latest   Up 5 minutes
worker-1     cpu-worker:latest   Up 5 minutes
producer-3   log-producer:1.0    Up 5 minutes
producer-2   log-producer:1.0    Up 6 minutes
producer-1   log-producer:1.0    Up 6 minutes

```



### Task 3: Custom output format - NAME | IMAGE | STATUS

**Command:**
```bash
echo "NAME | IMAGE | STATUS"
docker ps --format "{{.Names}} | {{.Image}} | {{.Status}}"
```

### Output:
```
NAME | IMAGE | STATUS
toolbox-1 | toolbox:latest | Up 6 minutes
worker-2 | cpu-worker:latest | Up 6 minutes
worker-1 | cpu-worker:latest | Up 6 minutes
producer-3 | log-producer:1.0 | Up 7 minutes
producer-2 | log-producer:1.0 | Up 7 minutes
producer-1 | log-producer:1.0 | Up 7 minutes
```

---

### Task 4: Show only container IDs of log-producer containers

**Command:**
```bash
docker ps --filter "ancestor=log-producer:1.0" --format "{{.ID}}"
```

### output:
```bash
59df8df5ade6
aab9ad8f2156
facbb01c7870

```
 


### Task 5: Show containers whose name matches `producer-*`

```bash
docker ps --filter "name=producer-" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
```
 
```

### Output

```bash

NAMES        IMAGE              STATUS
producer-3   log-producer:1.0   Up 8 minutes
producer-2   log-producer:1.0   Up 8 minutes
producer-1   log-producer:1.0   Up 8 minutes

```
