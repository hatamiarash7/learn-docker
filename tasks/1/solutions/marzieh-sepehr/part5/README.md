### Task 1: Container Age Analyzer
chmod +x task1-container-age.py
python3 task1-container-age.py


```
Output:**
```
================================================================================
  Container Age Analyzer
================================================================================

NAME                 | AGE_SECONDS  | IMAGE                     | tier      
---------------------+--------------+---------------------------+-----------
producer-1           | 1630         | log-producer:1.0          | backend   
producer-2           | 1615         | log-producer:1.0          | backend   
producer-3           | 1599         | log-producer:1.0          | backend   
worker-1             | 1584         | cpu-worker:latest         | worker    
worker-2             | 1569         | cpu-worker:latest         | worker    
toolbox-1            | 1553         | toolbox:latest            | utility   

Total containers analyzed: 6
```


---

### Task 2: Image Usage Detector

chmod +x task2-image-usage.py

# Run
python3 task2-image-usage.py


```

** Output:**
```
================================================================================
  Image Usage Detector
================================================================================

Total images found: 8

Images in use by running containers: 3

--------------------------------------------------------------------------------
Unused Images:
--------------------------------------------------------------------------------
alpine:latest -> UNUSED
new-ubun:latest -> UNUSED
python:3.13-slim -> UNUSED
ubuntu:22.04 -> UNUSED

================================================================================
Summary: 4 unused image(s) out of 8 total
================================================================================
```
 