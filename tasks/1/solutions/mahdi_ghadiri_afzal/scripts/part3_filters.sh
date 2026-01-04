#!/bin/bash

echo "=== Part 3: Docker PS Filtering ==="
echo ""

echo "Task 1: Containers with label tier=worker"
echo "-------------------------------------------"
docker ps --filter "label=tier=worker" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
echo ""

echo "Task 2: Containers started in last 2 minutes"
echo "---------------------------------------------"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
echo ""

echo "Task 3: Custom format (NAME | IMAGE | STATUS)"
echo "----------------------------------------------"
docker ps --format "{{.Names}} | {{.Image}} | {{.Status}}"
echo ""

echo "Task 4: Container IDs of log-producer"
echo "--------------------------------------"
docker ps --filter "label=app=log-producer" --format "{{.ID}}"
echo ""

echo "Task 5: Containers matching producer-*"
echo "---------------------------------------"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | grep -E "producer-|NAMES"
echo ""
