#!/bin/bash
echo "Part 3: Docker ps Filtering Examples"
echo "====================================="

echo -e "\n1. Containers with label tier=worker:"
docker ps --filter "label=tier=worker" --format "table {{.Names}} | {{.Image}} | {{.Status}}"

echo -e "\n2. Containers started recently:"
docker ps --filter "status=running" --format "table {{.Names}} | {{.Image}} | {{.Status}}" | head -10

echo -e "\n3. Container IDs of log-producer containers:"
docker ps --filter "label=app=log-producer" --format "{{.ID}}"

echo -e "\n4. Containers with name matching producer-*:"
docker ps --filter "name=producer-" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
