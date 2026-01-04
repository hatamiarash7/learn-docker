#!/bin/bash

echo "=== Part 2: Deploying Containers ==="
echo ""

wait_time=15

echo "Deploying log-producer containers..."
for i in {1..3}; do
    docker run -d --name producer-$i log-producer:1.0
    echo "Started producer-$i"
    [ $i -lt 3 ] && sleep $wait_time
done

sleep $wait_time

echo ""
echo "Deploying cpu-worker containers..."
for i in {1..2}; do
    docker run -d --name worker-$i cpu-worker:latest
    echo "Started worker-$i"
    [ $i -lt 2 ] && sleep $wait_time
done

sleep $wait_time

echo ""
echo "Deploying toolbox..."
docker run -d --name toolbox-1 toolbox:latest tail -f /dev/null
echo "Started toolbox-1"

echo ""
echo "=== Deployment Complete ==="
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
