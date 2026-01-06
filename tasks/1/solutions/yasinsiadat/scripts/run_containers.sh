#!/bin/bash
echo "Starting containers..."
echo "======================"

start_with_delay() {
    docker run -d --name "$1" "$2"
    echo "Started $1"
    sleep $3
}

docker rm -f producer-1 producer-2 producer-3 worker-1 worker-2 toolbox-1 2>/dev/null

start_with_delay "producer-1" "log-producer:stable" 10
start_with_delay "producer-2" "log-producer:stable" 10
start_with_delay "producer-3" "log-producer:stable" 10

start_with_delay "worker-1" "cpu-worker:latest" 10
start_with_delay "worker-2" "cpu-worker:latest" 10

start_with_delay "toolbox-1" "toolbox:latest" 5

echo -e "\nAll containers started:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
