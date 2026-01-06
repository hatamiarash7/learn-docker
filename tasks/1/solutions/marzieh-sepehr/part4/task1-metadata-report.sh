#!/bin/bash

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Container Metadata Report${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Print header
printf "%-20s | %-25s | %-15s | %-10s | %s\n" "CONTAINER_NAME" "IMAGE" "app" "tier" "start_time"
printf "%.20s-+-%.25s-+-%.15s-+-%.10s-+-%s\n" "--------------------" "-------------------------" "---------------" "----------" "-------------------"

# Get all running container IDs
container_ids=$(docker ps -q)

# Check if there are any running containers
if [ -z "$container_ids" ]; then
    echo "No running containers found."
    exit 0
fi

# Loop through each container
for container_id in $container_ids; do
    # Extract metadata using docker inspect
    name=$(docker inspect --format '{{.Name}}' $container_id | sed 's/\///')
    image=$(docker inspect --format '{{.Config.Image}}' $container_id)
    app_label=$(docker inspect --format '{{index .Config.Labels "app"}}' $container_id)
    tier_label=$(docker inspect --format '{{index .Config.Labels "tier"}}' $container_id)
    start_time=$(docker inspect --format '{{.State.StartedAt}}' $container_id | cut -d'.' -f1 | sed 's/T/ /')
    
    # Print formatted output
    printf "%-20s | %-25s | %-15s | %-10s | %s\n" "$name" "$image" "$app_label" "$tier_label" "$start_time"
done

echo ""
echo -e "${GREEN}Report completed!${NC}"