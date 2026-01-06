#!/usr/bin/env python3
import subprocess
import json
import time
from datetime import datetime

def get_container_age():
    """Calculate container age in seconds"""
    containers = []
    
    cmd = ["docker", "ps", "-q"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    container_ids = result.stdout.strip().split('\n')
    
    for cid in container_ids:
        if not cid:
            continue
            
        inspect_cmd = ["docker", "inspect", cid]
        inspect_result = subprocess.run(inspect_cmd, capture_output=True, text=True)
        
        if inspect_result.returncode == 0:
            data = json.loads(inspect_result.stdout)[0]
            
            started_at = data['State']['StartedAt']
            start_time = datetime.fromisoformat(started_at.replace('Z', '+00:00'))
            
            age_seconds = int((datetime.now(start_time.tzinfo) - start_time).total_seconds())
            
            containers.append({
                'name': data['Name'][1:],  
                'age': age_seconds,
                'image': data['Config']['Image'],
                'tier': data['Config']['Labels'].get('tier', 'N/A')
            })
    
    containers.sort(key=lambda x: x['age'], reverse=True)
    
    print(f"{'NAME':20} | {'AGE_SECONDS':12} | {'IMAGE':25} | {'TIER':10}")
    print("-" * 80)
    for c in containers:
        print(f"{c['name']:20} | {c['age']:12} | {c['image']:25} | {c['tier']:10}")

if __name__ == "__main__":
    get_container_age()
