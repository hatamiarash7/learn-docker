
#!/bin/bash

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Part 3 - Docker PS Filtering${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Task 1
echo -e "${GREEN}Task 1: Containers with label tier=worker${NC}"
echo -e "${YELLOW}Command: docker ps --filter \"label=tier=worker\" --format \"table {{.Names}}\t{{.Image}}\t{{.Status}}\"${NC}"
docker ps --filter "label=tier=worker" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
echo ""

# Task 2
echo -e "${GREEN}Task 2: Containers started in the last 2 minutes${NC}"
echo -e "${YELLOW}Command: docker ps --format \"table {{.Names}}\t{{.Image}}\t{{.Status}}\"${NC}"
echo "NAME            IMAGE                   STATUS"
docker ps --format "{{.Names}}\t{{.Image}}\t{{.Status}}" | awk '{if ($3 ~ /second/ || ($3 ~ /minute/ && $3 < 3)) print}'
echo ""

# Task 3
echo -e "${GREEN}Task 3: Custom format - NAME | IMAGE | STATUS${NC}"
echo -e "${YELLOW}Command: docker ps --format \"{{.Names}} | {{.Image}} | {{.Status}}\"${NC}"
echo "NAME | IMAGE | STATUS"
docker ps --format "{{.Names}} | {{.Image}} | {{.Status}}"
echo ""

# Task 4
echo -e "${GREEN}Task 4: Only container IDs of log-producer containers${NC}"
echo -e "${YELLOW}Command: docker ps --filter \"ancestor=log-producer:1.0\" --format \"{{.ID}}\"${NC}"
docker ps --filter "ancestor=log-producer:1.0" --format "{{.ID}}"
echo ""

# Task 5
echo -e "${GREEN}Task 5: Containers matching name pattern 'producer-*'${NC}"
echo -e "${YELLOW}Command: docker ps --filter \"name=producer-\" --format \"table {{.Names}}\t{{.Image}}\t{{.Status}}\"${NC}"
docker ps --filter "name=producer-" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  All tasks completed!${NC}"
echo -e "${BLUE}========================================${NC}"