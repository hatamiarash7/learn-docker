#!/usr/bin/env python3
import subprocess
import json

def get_all_images():
    result = subprocess.run(['docker', 'images', '--format', '{{.Repository}}:{{.Tag}}'], 
                          capture_output=True, text=True)
    return result.stdout.strip().split('\n')

def get_running_images():
    result = subprocess.run(['docker', 'ps', '--format', '{{.Image}}'], 
                          capture_output=True, text=True)
    return set(result.stdout.strip().split('\n'))

def main():
    all_images = get_all_images()
    running_images = get_running_images()
    
    print("Image Usage Report")
    print("-" * 60)
    
    for image in all_images:
        if image and image != '<none>:<none>':
            if image not in running_images:
                print(f"{image} -> UNUSED")
            else:
                print(f"{image} -> IN USE")

if __name__ == "__main__":
    main()
