#!/bin/bash
set -e 

echo "Building Docker images..."
echo "========================="

echo "Building log-producer..."
docker build -t log-producer:1.0 -t log-producer:stable -f dockerfiles/Dockerfile.log-producer .

echo "Building cpu-worker..."
docker build -t cpu-worker:latest -f dockerfiles/Dockerfile.cpu-worker .

echo "Building toolbox..."
docker build -t toolbox:latest -f dockerfiles/Dockerfile.toolbox .

echo -e "\nBuilt images:"
docker images | grep -E "(log-producer|cpu-worker|toolbox)"
