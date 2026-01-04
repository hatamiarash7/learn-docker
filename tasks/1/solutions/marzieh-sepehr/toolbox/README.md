# Toolbox Image


## Labels
- `app=toolbox`
- `tier=utility`
- `env=training`



## Build
```bash
docker pull python:3.13-slim
docker build -t toolbox:latest .
```

## Usage

### 1. Run info.py script
```bash
docker run --rm toolbox:latest python3 /opt/info.py
```

### output: 
```bash
Container information
---------------------

Hostname        : 743ad091ac9b
Container ID    : 743ad091ac9b
Current time    : 2026-01-04 12:40:04

OS Environment variables:
GPG_KEY              = 7169605F62C751356D054A26A821E680E5FA6305
HOME                 = /root
HOSTNAME             = 743ad091ac9b
LC_CTYPE             = C.UTF-8
PATH                 = /usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PYTHON_SHA256        = 16ede7bb7cdbfa895d11b0642fa0e523f291e6487194d53cf6d3b338c3a17ea2
PYTHON_VERSION       = 3.13.11
```

### 2. Run interactive Python shell (default)
```bash
docker run -it --rm toolbox:latest
```

### 3. Run custom commands
```bash
docker run --rm toolbox:latest python3 -c "print('Hello from toolbox')"
```

### 4. Use as debug container
```bash
# Run detached
docker run -d --name toolbox-1 toolbox:latest tail -f /dev/null

# Connect and run info.py
docker exec toolbox-1 python3 /opt/info.py

# Access shell
docker exec -it toolbox-1 /bin/bash
```

