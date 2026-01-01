#!/bin/bash

echo "Smart Worker Controller - Checking cpu-worker uptime..."
echo ""

for container in $(docker ps --filter "label=app=cpu-worker" -q); do
    name=$(docker inspect --format '{{.Name}}' $container | sed 's/\///')
    started_at=$(docker inspect --format '{{.State.StartedAt}}' $container)
    
    # Convert to seconds
    start_epoch=$(date -d "$started_at" +%s)
    current_epoch=$(date +%s)
    uptime=$((current_epoch - start_epoch))
    
    echo "Container: $name"
    echo "  Uptime: ${uptime} seconds"
    
    if [ $uptime -gt 300 ]; then
        echo "  Action: RESTARTING (uptime > 5 minutes)"
        docker restart $name
    else
        echo "  Action: NO ACTION NEEDED"
    fi
    echo ""
done

echo "Worker controller check complete."
