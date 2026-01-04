#!/usr/bin/env python3
import os
import socket
from datetime import datetime


def main():
    print("Container information")
    print("---------------------")

    hostname = socket.gethostname()
    container_id = hostname
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    print(f"\nHostname        : {hostname}")
    print(f"Container ID    : {container_id}")
    print(f"Current time    : {current_time}")

    print("\nOS Environment variables:")
    for key, value in sorted(os.environ.items()):
        print(f"  {key}={value}")


if __name__ == "__main__":
    main()
