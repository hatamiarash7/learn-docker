#!/bin/bash

echo "=== Part 4 Task 2: Policy Enforcement ==="
echo ""

stopped=0

for id in $(docker ps -q); do
    name=$(docker inspect --format '{{.Name}}' $id | sed 's/\///')
    env=$(docker inspect --format '{{index .Config.Labels "env"}}' $id)
    
    if [ "$env" != "training" ]; then
        echo "Stopping $name (env=$env)..."
        docker stop $name
        stopped=$((stopped + 1))
    fi
done

echo ""
[ $stopped -eq 0 ] && echo "All containers have env=training" || echo "Stopped $stopped containers"
