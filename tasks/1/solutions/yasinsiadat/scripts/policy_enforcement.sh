#!/bin/bash
echo "Policy Enforcement Script"
echo "========================="

echo "Checking containers for compliance..."

for container in $(docker ps -q); do
    env_label=$(docker inspect $container --format '{{index .Config.Labels "env"}}')
    
    if [ "$env_label" != "training" ] && [ ! -z "$env_label" ]; then
        container_name=$(docker inspect $container --format '{{.Name}}' | sed 's|/||g')
        echo "VIOLATION: $container_name has env=$env_label (should be 'training')"
        echo "Stopping container..."
        docker stop $container
    fi
done

echo "Policy check completed."
