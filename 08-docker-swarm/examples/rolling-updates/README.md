# Rolling Updates Demo

Demonstrates zero-downtime deployments with Docker Swarm rolling updates.

## How Rolling Updates Work

```
Timeline (parallelism=2, delay=15s):
────────────────────────────────────────────────────────────────────────────

T=0s    │ Update Task 1 │ Update Task 2 │
        └───────────────┴───────────────┘
                        │
T=15s   │               │ Update Task 3 │ Update Task 4 │
        └───────────────┴───────────────┴───────────────┘
                                        │
T=30s   │                               │ Update Task 5 │ Update Task 6 │
        └───────────────────────────────┴───────────────┴───────────────┘
                                                        │
T=45s   │                                               │ ✅ Update Complete
────────────────────────────────────────────────────────────────────────────
```

## Update Parameters Explained

| Parameter | Value | Description |
|-----------|-------|-------------|
| `parallelism` | 2 | Update 2 tasks simultaneously |
| `delay` | 15s | Wait 15s between batches |
| `monitor` | 10s | Watch new tasks for 10s |
| `max_failure_ratio` | 0.2 | Allow 20% failures before rollback |
| `failure_action` | rollback | Auto-rollback on failure |
| `order` | start-first | Start new before stopping old |

## Deploy

```bash
docker stack deploy -c docker-stack.yml rollingupdates
```

## Watch

Open two terminals:

**Terminal 1 - Watch tasks:**

```bash
watch docker service ps rollingupdates_web
```

**Terminal 2 - Or open visualizer:**

```bash
echo "Open http://localhost:8080"
```

## Perform Rolling Update

```bash
# Update to newer nginx version
docker service update --image nginx:1.25-alpine rollingupdates_web

# Watch the rolling update in Terminal 1 or visualizer
```

## Update Strategies

### Start-First (Zero Downtime)

```
Old Task: [  Running  ]─────────────────────[Stopped]
New Task:              [Starting]───[Running]────────►
                                     ↑
                            New ready, old stopped
```

### Stop-First (Brief Downtime)

```
Old Task: [  Running  ]───[Stopped]
New Task:                           [Starting]───[Running]───►
                           ↑
                   Old stopped before new starts
```

## Force Update (Restart All)

```bash
# Force update without image change (restarts all)
docker service update --force rollingupdates_web
```

## Simulate Failed Update

```bash
# Update to non-existent image
docker service update --image nginx:nonexistent rollingupdates_web

# Observe automatic rollback
watch docker service ps rollingupdates_web
```

## Manual Rollback

```bash
docker service rollback rollingupdates_web
```

## Verify Current Image

```bash
docker service inspect --pretty rollingupdates_web | grep -A 2 "Image"
```

## Clean Up

```bash
docker stack rm rollingupdates
```

## Best Practices

1. **Always set parallelism < total replicas**
   - Ensures some tasks are always running

2. **Use start-first for zero-downtime**
   - New task starts before old is stopped

3. **Set appropriate health checks**
   - Swarm waits for healthy status before continuing

4. **Use max_failure_ratio**
   - Prevents bad updates from affecting all tasks

5. **Set reasonable delays**
   - Give new tasks time to warm up
