#!/usr/bin/env python3

import subprocess
import json
import sys

def get_all_images():
    """Get list of all Docker images"""
    try:
        result = subprocess.run(
            ['docker', 'images', '--format', '{{.Repository}}:{{.Tag}}'],
            capture_output=True,
            text=True,
            check=True
        )
        images = result.stdout.strip().split('\n') if result.stdout.strip() else []
        # Filter out <none> images
        return [img for img in images if '<none>' not in img]
    except subprocess.CalledProcessError as e:
        print(f"Error getting images: {e}", file=sys.stderr)
        return []

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

def get_container_image(container_id):
    """Get image name from container using docker inspect"""
    try:
        result = subprocess.run(
            ['docker', 'inspect', '--format', '{{.Config.Image}}', container_id],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error inspecting container {container_id}: {e}", file=sys.stderr)
        return None

def main():
    print("=" * 80)
    print("  Image Usage Detector")
    print("=" * 80)
    print()
    
    # Get all images
    all_images = get_all_images()
    
    if not all_images:
        print("No images found.")
        return
    
    print(f"Total images found: {len(all_images)}")
    print()
    
    # Get all running containers
    container_ids = get_running_containers()
    
    # Get images used by running containers
    used_images = set()
    for container_id in container_ids:
        image = get_container_image(container_id)
        if image:
            used_images.add(image)
    
    print(f"Images in use by running containers: {len(used_images)}")
    print()
    
    # Find unused images
    unused_images = []
    for image in all_images:
        # Check if image is used
        # Handle both with and without tag
        image_base = image.split(':')[0]
        is_used = False
        
        for used_img in used_images:
            if image in used_img or image_base in used_img:
                is_used = True
                break
        
        if not is_used:
            unused_images.append(image)
    
    # Print results
    print("-" * 80)
    print("Unused Images:")
    print("-" * 80)
    
    if unused_images:
        for image in sorted(unused_images):
            print(f"{image} -> UNUSED")
    else:
        print("All images are currently in use!")
    
    print()
    print("=" * 80)
    print(f"Summary: {len(unused_images)} unused image(s) out of {len(all_images)} total")
    print("=" * 80)

if __name__ == "__main__":
    main()