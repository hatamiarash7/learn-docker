import os
import socket
from datetime import datetime

def main():
    print("Container information")
    print("---------------------")

    # socket.gethostname() usually returns the Container ID in Docker
    print(f"Hostname        : {socket.gethostname()}")
    print(f"Container ID    : {os.environ.get('HOSTNAME', 'Not Set')}")
    # print(f"Current time    : {datetime.now()}")
    print(f"Current time    : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    print("\nOS Environment variables:")
    for key, value in os.environ.items():
        print(f"{key}={value}")

if __name__ == "__main__":
    main() 
