import os
import socket
import datetime
import json
import subprocess

def main():
    print("=" * 50)
    print("Container Information")
    print("=" * 50)
    
    hostname = socket.gethostname()
    print(f"Hostname        : {hostname}")
    print(f"Container ID    : {os.environ.get('HOSTNAME', hostname)}")
    print(f"Current time    : {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    try:
        container_id = os.environ.get('HOSTNAME', 'unknown')
        result = subprocess.run(['docker', 'inspect', container_id], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            data = json.loads(result.stdout)[0]
            print(f"\nDocker Metadata:")
            print(f"  Image: {data['Config']['Image']}")
            print(f"  Created: {data['Created']}")
            print(f"  State: {data['State']['Status']}")
    except Exception as e:
        print(f"\nNote: Docker inspect not available in this context")
    
    print("\nEnvironment Variables:")
    print("-" * 30)
    for key in sorted(os.environ.keys()):
        if not key.startswith('_') and len(key) < 30:
            print(f"{key:20} = {os.environ[key][:50]}")

if __name__ == "__main__":
    main()
