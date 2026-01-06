#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Policy Enforcement Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Checking for containers with env != training...${NC}"
echo ""

# Get all running container IDs
container_ids=$(docker ps -q)

# Check if there are any running containers
if [ -z "$container_ids" ]; then
    echo -e "${GREEN}No running containers found.${NC}"
    exit 0
fi

# Counter for violations
violation_count=0

# Loop through each container
for container_id in $container_ids; do
    # Get container name and env label
    name=$(docker inspect --format '{{.Name}}' $container_id | sed 's/\///')
    env_label=$(docker inspect --format '{{index .Config.Labels "env"}}' $container_id)
    
    # Check if env label exists and is not "training"
    if [ -n "$env_label" ] && [ "$env_label" != "training" ]; then
        echo -e "${RED}[VIOLATION] Container: $name (env=$env_label)${NC}"
        echo -e "${YELLOW}  Stopping container...${NC}"
        
        # Stop the container
        docker stop $name > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}  ✓ Container stopped successfully${NC}"
            ((violation_count++))
        else
            echo -e "${RED}  ✗ Failed to stop container${NC}"
        fi
        echo ""
    fi
done

echo -e "${BLUE}========================================${NC}"
if [ $violation_count -eq 0 ]; then
    echo -e "${GREEN}No policy violations found. All containers are compliant.${NC}"
else
    echo -e "${YELLOW}Total violations found and stopped: $violation_count${NC}"
fi
echo -e "${BLUE}========================================${NC}"