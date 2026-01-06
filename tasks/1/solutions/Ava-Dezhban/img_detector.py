import subprocess
import json

def detect_unused_images():
    print(f"{'IMAGE:TAG':<35} -> STATUS")
    print("-" * 50)

    # 1. Get all images with their IDs and Names
    # Format: ID|Repository:Tag
    raw_images = subprocess.check_output(
        ["docker", "images", "--format", "{{.ID}}|{{.Repository}}:{{.Tag}}"]
    ).decode().strip().splitlines()

    # 2. Get the Image IDs of all RUNNING containers
    # We use 'docker ps' and then 'inspect' each container to get the EXACT image ID it uses
    running_cids = subprocess.check_output(["docker", "ps", "-q"]).decode().strip().splitlines()
    
    used_image_ids = set()
    for cid in running_cids:
        # Get the Image ID directly from inspect
        img_id = subprocess.check_output(
            ["docker", "inspect", "--format", "{{.Image}}", cid]
        ).decode().strip()
        used_image_ids.add(img_id)

    # 3. Compare
    found_unused = False
    for line in raw_images:
        img_id, img_name = line.split('|')
        
        # We need the full ID to compare against the used_image_ids set
        full_id = subprocess.check_output(
            ["docker", "inspect", "--format", "{{.Id}}", img_id]
        ).decode().strip()

        if full_id not in used_image_ids:
            print(f"{img_name:<35} -> UNUSED")
            found_unused = True

    if not found_unused:
        print("No unused images found. All images are currently running.")

if __name__ == "__main__":
    detect_unused_images()