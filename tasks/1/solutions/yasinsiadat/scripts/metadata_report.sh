#!/bin/bash
echo "Container Metadata Report"
echo "========================="
echo "CONTAINER_NAME | IMAGE | app | tier | start_time"
echo "-------------------------------------------------"

for container in $(docker ps -q); do
    # Get container name (remove leading '/')
    name=$(docker inspect $container --format '{{.Name}}' | sed 's|/||g')
    
    # Get image name
    image=$(docker inspect $container --format '{{.Config.Image}}')
    
    # Get labels
    app=$(docker inspect $container --format '{{index .Config.Labels "app"}}')
    tier=$(docker inspect $container --format '{{index .Config.Labels "tier"}}')
    
    # Get start time
    start_time=$(docker inspect $container --format '{{.State.StartedAt}}' | cut -d'.' -f1 | sed 's/T/ /')
    
    echo "$name | $image | $app | $tier | $start_time"
done
