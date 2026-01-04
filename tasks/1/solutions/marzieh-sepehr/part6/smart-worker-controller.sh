#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Uptime threshold in seconds (5 minutes = 300 seconds)
THRESHOLD=300

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Smart Worker Controller${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Threshold: ${THRESHOLD} seconds (5 minutes)${NC}"
echo ""

# Get all running container IDs
container_ids=$(docker ps -q)

if [ -z "$container_ids" ]; then
    echo -e "${YELLOW}No running containers found.${NC}"
    exit 0
fi

# Counter for actions
restart_count=0
skip_count=0

# Loop through each container
for container_id in $container_ids; do
    # Get app label
    app_label=$(docker inspect --format '{{index .Config.Labels "app"}}' $container_id)
    
    # Check if this is a cpu-worker
    if [ "$app_label" != "cpu-worker" ]; then
        continue
    fi
    
    # Get container name
    name=$(docker inspect --format '{{.Name}}' $container_id | sed 's/\///')
    
    # Get start time (ISO 8601 format)
    started_at=$(docker inspect --format '{{.State.StartedAt}}' $container_id)
    
    # Convert start time to epoch seconds
    # Remove timezone and nanoseconds for cross-platform compatibility
    started_epoch=$(date -d "${started_at%.*}" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "${started_at%.*}" +%s 2>/dev/null)
    
    # Get current time in epoch seconds
    current_epoch=$(date +%s)
    
    # Calculate uptime
    uptime=$((current_epoch - started_epoch))
    
    echo -e "${BLUE}Container: ${name}${NC}"
    echo "  App Label: $app_label"
    echo "  Uptime: ${uptime} seconds"
    
    # Check if uptime exceeds threshold
    if [ $uptime -gt $THRESHOLD ]; then
        echo -e "  ${RED}⚠ Uptime exceeds threshold (${uptime}s > ${THRESHOLD}s)${NC}"
        echo -e "  ${YELLOW}→ Restarting container...${NC}"
        
        docker restart $name > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✓ Container restarted successfully${NC}"
            ((restart_count++))
        else
            echo -e "  ${RED}✗ Failed to restart container${NC}"
        fi
    else
        echo -e "  ${GREEN}✓ Uptime within threshold (${uptime}s < ${THRESHOLD}s)${NC}"
        echo -e "  ${BLUE}→ No action needed${NC}"
        ((skip_count++))
    fi
    
    echo ""
done

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Summary:${NC}"
echo "  Containers restarted: $restart_count"
echo "  Containers skipped: $skip_count"
echo -e "${BLUE}========================================${NC}"