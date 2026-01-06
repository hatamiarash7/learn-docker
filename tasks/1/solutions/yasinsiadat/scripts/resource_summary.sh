#!/bin/bash
echo "Resource Usage Summary"
echo "======================"

docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}" | \
while read line; do
    echo "$line" | sed 's|/||g'
done
