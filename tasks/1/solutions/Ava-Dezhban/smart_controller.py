import subprocess
import json
from datetime import datetime, timezone

def main():
    print("Checking CPU Workers for uptime policy...")
    
    # 1. Get IDs of containers that have the label app=cpu-worker
    # Using subprocess to run the command just like a human in the terminal
    cmd = ["docker", "ps", "-q", "--filter", "label=app=cpu-worker"]
    worker_ids = subprocess.check_output(cmd).decode().splitlines()

    if not worker_ids:
        print("No cpu-worker containers are currently running.")
        return

    # Get the time right now in UTC (Docker always uses UTC for its internal logs)
    now = datetime.now(timezone.utc)

    for cid in worker_ids:
        # 2. Use docker inspect to get the raw data for this container
        inspect_raw = subprocess.check_output(["docker", "inspect", cid]).decode()
        data = json.loads(inspect_raw)[0]
        
        name = data['Name'].lstrip('/')
        
        # 3. Get the 'StartedAt' time and convert it to a Python time object
        # We slice the string [:26] to keep the format clean
        start_time_str = data['State']['StartedAt'][:26] + 'Z'
        start_time = datetime.strptime(start_time_str, "%Y-%m-%dT%H:%M:%S.%fZ").replace(tzinfo=timezone.utc)
        
        # 4. Calculate how long it has been running in minutes
        uptime_seconds = (now - start_time).total_seconds()
        uptime_minutes = uptime_seconds / 60

        print(f"Checking {name}: Uptime is {uptime_minutes:.2f} minutes")

        # 5. Logic: If uptime > 5 minutes, Restart it
        if uptime_minutes > 5:
            print(f"!!! {name} has been running too long. Restarting now...")
            subprocess.run(["docker", "restart", cid])
        else:
            print(f"--- {name} is still fresh. No action needed.")

if __name__ == "__main__":
    main()
