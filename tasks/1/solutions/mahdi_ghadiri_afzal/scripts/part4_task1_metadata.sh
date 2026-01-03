#!/bin/bash

echo "=== Part 4 Task 1: Container Metadata Report ==="
echo ""
echo "CONTAINER_NAME | IMAGE | app | tier | start_time"
echo "-------------------------------------------------"

for id in $(docker ps -q); do
    name=$(docker inspect --format '{{.Name}}' $id | sed 's/\///')
    image=$(docker inspect --format '{{.Config.Image}}' $id)
    app=$(docker inspect --format '{{index .Config.Labels "app"}}' $id)
    tier=$(docker inspect --format '{{index .Config.Labels "tier"}}' $id)
    start_time=$(docker inspect --format '{{.State.StartedAt}}' $id)
    
    echo "$name | $image | $app | $tier | $start_time"
done
