#!/bin/bash

echo "=== Cleanup ==="

docker stop $(docker ps -q) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null

echo "Done"
docker ps -a
