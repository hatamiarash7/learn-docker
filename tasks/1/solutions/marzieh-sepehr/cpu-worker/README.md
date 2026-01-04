# CPU Worker Image


## Labels
- `app=cpu-worker`
- `tier=worker`
- `env=training`

## Build
```bash
docker build -t cpu-worker:latest .
```

## Test
```bash

docker run --rm cpu-worker:latest
docker run -d --name test-worker cpu-worker:latest

# 
docker logs -f test-worker

## output :
[CPU-WORKER] Started
[CPU-WORKER] Working... Done (19025969 operations)
[CPU-WORKER] Resting...
[CPU-WORKER] Working... Done (18992468 operations)
[CPU-WORKER] Resting...



# see how much usage does it have 
docker stats test-worker

## output 

CONTAINER ID   NAME          CPU %     MEM USAGE / LIMIT     MEM %     NET I/O         BLOCK I/O   PIDS 
498ce37af98c   test-worker   0.00%     3.387MiB / 15.24GiB   0.02%     3.87kB / 126B   0B / 0B     1 
 

```


## فایل‌ها
- `Dockerfile`: تعریف image
- `worker.py`: اسکریپت Python برای CPU workload (اختیاری)