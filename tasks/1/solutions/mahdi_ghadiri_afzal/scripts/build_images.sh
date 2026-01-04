#!/bin/bash

echo "=== Building Docker Images ==="
echo ""

echo "Building log-producer..."
docker build -t log-producer:1.0 -f dockerfiles/Dockerfile.log-producer .
docker tag log-producer:1.0 log-producer:stable
echo "log-producer built"
echo ""

echo "Building cpu-worker..."
docker build -t cpu-worker:latest -f dockerfiles/Dockerfile.cpu-worker .
echo "cpu-worker built"
echo ""

echo "Building toolbox..."
docker build -t toolbox:latest -f dockerfiles/Dockerfile.toolbox .
echo "toolbox built"
echo ""

echo "=== Done ==="
docker images | grep -E "log-producer|cpu-worker|toolbox"
