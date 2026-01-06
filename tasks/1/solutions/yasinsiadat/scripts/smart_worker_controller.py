#!/usr/bin/env python3
import subprocess
import json
from datetime import datetime

def control_workers():
    """Control cpu-worker containers based on uptime"""
    print("Smart Worker Controller")
    print("=" * 50)
    
    cmd = ["docker", "ps", "--filter", "label=app=cpu-worker", "--format", "{{.ID}}"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    worker_ids = result.stdout.strip().split('\n')
    
    for wid in worker_ids:
        if not wid:
            continue
            
        inspect_cmd = ["docker", "inspect", wid]
        inspect_result = subprocess.run(inspect_cmd, capture_output=True, text=True)
        
        if inspect_result.returncode == 0:
            data = json.loads(inspect_result.stdout)[0]
            container_name = data['Name'][1:]
            
            started_at = data['State']['StartedAt']
            start_time = datetime.fromisoformat(started_at.replace('Z', '+00:00'))
            uptime_minutes = (datetime.now(start_time.tzinfo) - start_time).total_seconds() / 60
            
            print(f"\nContainer: {container_name}")
            print(f"  Uptime: {uptime_minutes:.2f} minutes")
            
            if uptime_minutes > 5:
                print(f"  ACTION: Restarting (uptime > 5 minutes)")
                subprocess.run(["docker", "restart", wid])
                print(f"  Restarted successfully")
            else:
                print(f"  STATUS: OK (uptime <= 5 minutes)")

if __name__ == "__main__":
    control_workers()
