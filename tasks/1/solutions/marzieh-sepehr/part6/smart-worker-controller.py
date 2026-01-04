#!/usr/bin/env python3

import subprocess
import json
from datetime import datetime
import sys

# Uptime threshold in seconds (5 minutes)
THRESHOLD = 300

def get_running_containers():
    """Get list of all running container IDs"""
    try:
        result = subprocess.run(
            ['docker', 'ps', '-q'],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip().split('\n') if result.stdout.strip() else []
    except subprocess.CalledProcessError as e:
        print(f"Error getting containers: {e}", file=sys.stderr)
        return []

def get_container_info(container_id):
    """Get container information using docker inspect"""
    try:
        result = subprocess.run(
            ['docker', 'inspect', container_id],
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)[0]
    except (subprocess.CalledProcessError, json.JSONDecodeError, IndexError) as e:
        print(f"Error inspecting container {container_id}: {e}", file=sys.stderr)
        return None

def calculate_uptime(started_at_str):
    """Calculate container uptime in seconds"""
    try:
        # Parse ISO 8601 format
        started_at = datetime.fromisoformat(started_at_str.replace('Z', '+00:00'))
        current_time = datetime.now(started_at.tzinfo)
        uptime = (current_time - started_at).total_seconds()
        return int(uptime)
    except Exception as e:
        print(f"Error calculating uptime: {e}", file=sys.stderr)
        return 0

def restart_container(container_name):
    """Restart a container"""
    try:
        result = subprocess.run(
            ['docker', 'restart', container_name],
            capture_output=True,
            text=True,
            check=True
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error restarting container {container_name}: {e}", file=sys.stderr)
        return False

def main():
    print("=" * 80)
    print("  Smart Worker Controller")
    print("=" * 80)
    print()
    print(f"Threshold: {THRESHOLD} seconds (5 minutes)")
    print()
    
    # Get all running containers
    container_ids = get_running_containers()
    
    if not container_ids:
        print("No running containers found.")
        return
    
    restart_count = 0
    skip_count = 0
    
    # Check each container
    for container_id in container_ids:
        info = get_container_info(container_id)
        if not info:
            continue
        
        # Get app label
        app_label = info['Config']['Labels'].get('app', '')
        
        # Check if this is a cpu-worker
        if app_label != 'cpu-worker':
            continue
        
        # Get container details
        name = info['Name'].lstrip('/')
        started_at = info['State']['StartedAt']
        
        # Calculate uptime
        uptime = calculate_uptime(started_at)
        
        print(f"Container: {name}")
        print(f"  App Label: {app_label}")
        print(f"  Uptime: {uptime} seconds")
        
        # Check if uptime exceeds threshold
        if uptime > THRESHOLD:
            print(f"  ⚠ Uptime exceeds threshold ({uptime}s > {THRESHOLD}s)")
            print(f"  → Restarting container...")
            
            if restart_container(name):
                print(f"  ✓ Container restarted successfully")
                restart_count += 1
            else:
                print(f"  ✗ Failed to restart container")
        else:
            print(f"  ✓ Uptime within threshold ({uptime}s < {THRESHOLD}s)")
            print(f"  → No action needed")
            skip_count += 1
        
        print()
    
    print("=" * 80)
    print("Summary:")
    print(f"  Containers restarted: {restart_count}")
    print(f"  Containers skipped: {skip_count}")
    print("=" * 80)

if __name__ == "__main__":
    main()