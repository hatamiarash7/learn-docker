#!/usr/bin/env python3
import subprocess


def get_all_images():
    result = subprocess.run(
        ["docker", "images", "--format", "{{.Repository}}:{{.Tag}}"],
        capture_output=True,
        text=True,
    )
    images = result.stdout.strip().split("\n")
    return [img for img in images if img and img != "<none>:<none>"]


def get_used_images():
    result = subprocess.run(["docker", "ps", "-q"], capture_output=True, text=True)
    containers = result.stdout.strip().split("\n")

    used = set()
    for cid in containers:
        if cid:
            r = subprocess.run(
                ["docker", "inspect", "--format", "{{.Config.Image}}", cid],
                capture_output=True,
                text=True,
            )
            used.add(r.stdout.strip())
    return used


def main():
    print("=== Part 5 Task 2: Image Usage Detector ===\n")
    print("Unused Images:")
    print("-" * 40)

    all_images = get_all_images()
    used_images = get_used_images()

    unused = 0
    for image in all_images:
        image_base = image.split(":")[0]
        is_used = any(image in used or image_base in used for used in used_images)

        if not is_used:
            print(f"{image} -> UNUSED")
            unused += 1

    if unused == 0:
        print("All images are in use!")
    else:
        print(f"\nTotal unused: {unused}")


if __name__ == "__main__":
    main()
