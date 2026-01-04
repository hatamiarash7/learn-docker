#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Container Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to wait with countdown
wait_with_countdown() {
    local seconds=$1
    echo -e "${YELLOW}Waiting ${seconds} seconds...${NC}"
    for i in $(seq $seconds -1 1); do
        echo -ne "${YELLOW}  $i seconds remaining...\r${NC}"
        sleep 1
    done
    echo -e "${GREEN}  Ready!                    ${NC}"
}

# Deploy log-producer containers
echo -e "${GREEN}[1/6] Starting producer-1...${NC}"
docker run -d --name producer-1 log-producer:1.0
wait_with_countdown 15

echo -e "${GREEN}[2/6] Starting producer-2...${NC}"
docker run -d --name producer-2 log-producer:1.0
wait_with_countdown 15

echo -e "${GREEN}[3/6] Starting producer-3...${NC}"
docker run -d --name producer-3 log-producer:1.0
wait_with_countdown 15

# Deploy cpu-worker containers
echo -e "${GREEN}[4/6] Starting worker-1...${NC}"
docker run -d --name worker-1 cpu-worker:latest
wait_with_countdown 15

echo -e "${GREEN}[5/6] Starting worker-2...${NC}"
docker run -d --name worker-2 cpu-worker:latest
wait_with_countdown 15

# Deploy toolbox container
echo -e "${GREEN}[6/6] Starting toolbox-1...${NC}"
docker run -d --name toolbox-1 toolbox:latest tail -f /dev/null

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  All containers deployed!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Show running containers
echo -e "${YELLOW}Running containers:${NC}"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"