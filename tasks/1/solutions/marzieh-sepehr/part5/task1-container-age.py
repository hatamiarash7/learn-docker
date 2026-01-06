#!/usr/bin/env python3

import subprocess
import json
from datetime import datetime
import sys

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

def calculate_age(started_at_str):
    """Calculate container age in seconds"""
    try:
        # Parse ISO 8601 format: 2026-01-04T16:30:15.123456789Z
        started_at = datetime.fromisoformat(started_at_str.replace('Z', '+00:00'))
        current_time = datetime.now(started_at.tzinfo)
        age = (current_time - started_at).total_seconds()
        return int(age)
    except Exception as e:
        print(f"Error calculating age: {e}", file=sys.stderr)
        return 0

def main():
    print("=" * 80)
    print("  Container Age Analyzer")
    print("=" * 80)
    print()
    
    # Get all running containers
    container_ids = get_running_containers()
    
    if not container_ids:
        print("No running containers found.")
        return
    
    # Collect container information
    containers_info = []
    
    for container_id in container_ids:
        info = get_container_info(container_id)
        if not info:
            continue
        
        # Extract data
        name = info['Name'].lstrip('/')
        image = info['Config']['Image']
        started_at = info['State']['StartedAt']
        tier = info['Config']['Labels'].get('tier', 'N/A')
        
        # Calculate age
        age_seconds = calculate_age(started_at)
        
        containers_info.append({
            'name': name,
            'age_seconds': age_seconds,
            'image': image,
            'tier': tier
        })
    
    # Sort by oldest first (highest age_seconds)
    containers_info.sort(key=lambda x: x['age_seconds'], reverse=True)
    
    # Print header
    print(f"{'NAME':<20} | {'AGE_SECONDS':<12} | {'IMAGE':<25} | {'tier':<10}")
    print("-" * 20 + "-+-" + "-" * 12 + "-+-" + "-" * 25 + "-+-" + "-" * 10)
    
    # Print results
    for container in containers_info:
        print(f"{container['name']:<20} | {container['age_seconds']:<12} | {container['image']:<25} | {container['tier']:<10}")
    
    print()
    print(f"Total containers analyzed: {len(containers_info)}")
    print("=" * 80)

if __name__ == "__main__":
    main()