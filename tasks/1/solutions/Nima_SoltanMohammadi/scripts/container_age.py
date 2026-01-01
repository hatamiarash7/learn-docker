#!/usr/bin/env python3
import subprocess
import json
from datetime import datetime

def get_running_containers():
    result = subprocess.run(['docker', 'ps', '-q'], capture_output=True, text=True)
    return result.stdout.strip().split('\n')

def get_container_info(container_id):
    result = subprocess.run(['docker', 'inspect', container_id], capture_output=True, text=True)
    return json.loads(result.stdout)[0]

def calculate_age(started_at):
    start_time = datetime.fromisoformat(started_at.replace('Z', '+00:00'))
    current_time = datetime.now(start_time.tzinfo)
    age_seconds = int((current_time - start_time).total_seconds())
    return age_seconds

def main():
    containers = get_running_containers()
    container_data = []
    
    for cid in containers:
        if not cid:
            continue
        info = get_container_info(cid)
        
        name = info['Name'].lstrip('/')
        started_at = info['State']['StartedAt']
        image = info['Config']['Image']
        tier = info['Config']['Labels'].get('tier', 'N/A')
        age = calculate_age(started_at)
        
        container_data.append({
            'name': name,
            'age': age,
            'image': image,
            'tier': tier
        })
    
    # Sort by oldest first
    container_data.sort(key=lambda x: x['age'], reverse=True)
    
    print("NAME | AGE_SECONDS | IMAGE | tier")
    print("-" * 60)
    for c in container_data:
        print(f"{c['name']} | {c['age']} | {c['image']} | {c['tier']}")

if __name__ == "__main__":
    main()
