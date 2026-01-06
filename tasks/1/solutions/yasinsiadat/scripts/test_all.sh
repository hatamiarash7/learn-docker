#!/bin/bash
echo "Testing Docker Task 1 Solution"
echo "==============================="

# Clean up old containers
echo "Cleaning up old containers..."
docker rm -f $(docker ps -aq) 2>/dev/null

# Rebuild images
echo -e "\n1. Rebuilding images..."
./build_images.sh

# Run containers
echo -e "\n2. Running containers..."
./run_containers.sh

# Wait a bit
echo -e "\n3. Waiting for containers to initialize..."
sleep 5

# Check if containers are running
echo -e "\n4. Checking container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

# Test scripts one by one
echo -e "\n5. Testing scripts:"
echo -e "\n--- Docker Filters ---"
./docker_filters.sh

echo -e "\n--- Metadata Report ---"
./metadata_report.sh

echo -e "\n--- Resource Summary ---"
./resource_summary.sh

echo -e "\n--- Python Scripts ---"
python3 container_age_analyzer.py
python3 image_usage_detector.py
