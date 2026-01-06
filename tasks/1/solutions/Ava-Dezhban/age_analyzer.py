import subprocess
import json
from datetime import datetime, timezone

def analyze_age():
    # 1. Lists all running containers
    ids = subprocess.check_output(["docker", "ps", "-q"]).decode().splitlines()
    
    container_list = []
    # Get current time with local timezone info
    now = datetime.now(timezone.utc).astimezone()

    for cid in ids:
        # 2. Uses docker inspect
        raw_json = subprocess.check_output(["docker", "inspect", cid]).decode()
        data = json.loads(raw_json)[0]
        
        name = data['Name'].lstrip('/')
        image = data['Config']['Image']
        tier = data['Config']['Labels'].get('tier', 'N/A')
        
        # 3. Parse StartedAt (Docker always stores this in UTC)
        # We parse it as UTC and then convert it to your local time for the math
        start_str = data['State']['StartedAt'][:26] + 'Z'
        start_time_utc = datetime.strptime(start_str, "%Y-%m-%dT%H:%M:%S.%fZ").replace(tzinfo=timezone.utc)
        start_time_local = start_time_utc.astimezone()
        
        # 4. Calculate age: current_local_time - started_local_time
        age_seconds = int((now - start_time_local).total_seconds())
        
        container_list.append({
            "name": name, 
            "age": age_seconds, 
            "image": image, 
            "tier": tier
        })

    # 5. Sort by oldest (highest age)
    container_list.sort(key=lambda x: x['age'], reverse=True)

    print(f"{'NAME':<15} | {'AGE_SECONDS':<12} | {'IMAGE':<18} | {'TIER'}")
    print("-" * 65)
    for c in container_list:
        print(f"{c['name']:<15} | {c['age']:<12} | {c['image']:<18} | {c['tier']}")

if __name__ == "__main__":
    analyze_age()
