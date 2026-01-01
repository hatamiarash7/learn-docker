#!/bin/bash

echo "Checking containers for env != training..."
echo ""

for container in $(docker ps -q); do
    name=$(docker inspect --format '{{.Name}}' $container | sed 's/\///')
    env_label=$(docker inspect --format '{{index .Config.Labels "env"}}' $container)
    
    if [ "$env_label" != "training" ]; then
        echo "Found non-training container: $name (env=$env_label)"
        echo "Stopping $name..."
        docker stop $name
    fi
done

echo "Policy enforcement complete."
