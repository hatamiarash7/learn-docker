#!/bin/bash

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Resource Usage Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Print header
printf "%-20s | %-10s | %s\n" "NAME" "CPU%" "MEM%"
printf "%.20s-+-%.10s-+-%s\n" "--------------------" "----------" "----------"

# Get stats for all running containers
# docker stats --no-stream gives us a one-time snapshot
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}" | tail -n +2 | while read line; do
    name=$(echo $line | awk '{print $1}')
    cpu=$(echo $line | awk '{print $2}')
    mem=$(echo $line | awk '{print $3}')
    
    printf "%-20s | %-10s | %s\n" "$name" "$cpu" "$mem"
done

echo ""
echo -e "${GREEN}Resource usage summary completed!${NC}"

