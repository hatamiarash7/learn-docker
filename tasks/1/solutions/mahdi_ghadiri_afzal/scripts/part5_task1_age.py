#!/usr/bin/env python3
import json
import subprocess
from datetime import datetime, timezone


def get_running_containers():
    result = subprocess.run(["docker", "ps", "-q"], capture_output=True, text=True)
    return result.stdout.strip().split("\n")


def get_container_info(container_id):
    result = subprocess.run(
        ["docker", "inspect", container_id], capture_output=True, text=True
    )
    return json.loads(result.stdout)[0]


def parse_timestamp(ts):
    if "." in ts:
        ts = ts.split(".")[0] + "Z"
    return datetime.fromisoformat(ts.replace("Z", "+00:00"))


def main():
    print("=== Part 5 Task 1: Container Age Analyzer ===\n")
    print("NAME | AGE_SECONDS | IMAGE | tier")
    print("-" * 60)

    containers = []

    for cid in get_running_containers():
        if not cid:
            continue

        info = get_container_info(cid)
        name = info["Name"].lstrip("/")
        image = info["Config"]["Image"]
        tier = info["Config"]["Labels"].get("tier", "N/A")
        start_time = parse_timestamp(info["State"]["StartedAt"])
        age = int((datetime.now(timezone.utc) - start_time).total_seconds())

        containers.append({"name": name, "age": age, "image": image, "tier": tier})

    containers.sort(key=lambda x: x["age"], reverse=True)

    for c in containers:
        print(f"{c['name']} | {c['age']} | {c['image']} | {c['tier']}")


if __name__ == "__main__":
    main()
