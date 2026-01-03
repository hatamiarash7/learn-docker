#!/bin/bash

echo "=== Part 4 Task 3: Resource Usage ==="
echo ""
echo "NAME | CPU% | MEM%"
echo "-------------------"

docker stats --no-stream --format "{{.Name}} | {{.CPUPerc}} | {{.MemPerc}}"
