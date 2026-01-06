#!/usr/bin/env python3
import subprocess
import json

def detect_unused_images():
    """Find images with no running containers"""
    cmd = ["docker", "images", "--format", "{{.Repository}}:{{.Tag}}"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    all_images = [img for img in result.stdout.strip().split('\n') if img and '<none>' not in img]
    
    cmd = ["docker", "ps", "--format", "{{.Image}}"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    used_images = set(result.stdout.strip().split('\n'))
    
    print("UNUSED IMAGES DETECTION")
    print("=" * 50)
    print(f"Total images: {len(all_images)}")
    print(f"Images in use: {len(used_images)}")
    print(f"Unused images: {len(all_images) - len(used_images)}")
    print("\n" + "=" * 50)
    
    unused = []
    for image in all_images:
        if image not in used_images:
            unused.append(image)
    
    if unused:
        print("Unused Images:")
        for img in unused:
            print(f"  {img} -> UNUSED")
    else:
        print("No unused images found.")
    
    return unused

if __name__ == "__main__":
    detect_unused_images()
