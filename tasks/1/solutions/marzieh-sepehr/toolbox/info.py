#!/usr/bin/env python3

import os
import socket
from datetime import datetime

def get_container_id():
    """
    Read Container ID from cgroup
    """
    try:
        with open('/proc/self/cgroup', 'r') as f:
            for line in f:
                if 'docker' in line or 'kubepods' in line:
                    parts = line.strip().split('/')
                    if len(parts) > 0:
                        container_id = parts[-1]
                        if container_id.startswith('docker-'):
                            container_id = container_id[7:]
                        if container_id.endswith('.scope'):
                            container_id = container_id[:-6]
                        return container_id[:12]
    except:
        pass
    
    return socket.gethostname()[:12]

def main():
    print("Container information")
    print("---------------------")

    print(f"\nHostname        : {socket.gethostname()}")
    print(f"Container ID    : {get_container_id()}")
    print(f"Current time    : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    print("\nOS Environment variables:")
    # Print all available environment variables inside container
    for key, value in sorted(os.environ.items()):
        print(f"{key:20s} = {value}")

if __name__ == "__main__":
    main()