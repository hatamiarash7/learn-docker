#!/bin/bash

echo "=== Part 6: Smart Worker Controller ==="
echo ""

for id in $(docker ps -q); do
    app=$(docker inspect --format '{{index .Config.Labels "app"}}' $id)
    
    if [ "$app" = "cpu-worker" ]; then
        name=$(docker inspect --format '{{.Name}}' $id | sed 's/\///')
        started=$(docker inspect --format '{{.State.StartedAt}}' $id)
        
        start_sec=$(date -d "$started" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "${started%.*}" +%s 2>/dev/null)
        current_sec=$(date +%s)
        uptime=$((current_sec - start_sec))
        uptime_min=$((uptime / 60))
        
        echo "Container: $name"
        echo "  Uptime: $uptime_min minutes"
        
        if [ $uptime -gt 300 ]; then
            echo "  Action: RESTARTING (> 5 min)"
            docker restart $name
        else
            echo "  Action: OK"
        fi
        echo ""
    fi
done

echo "Check complete"
