#!/bin/bash

# Header
echo "CONTAINER_NAME | IMAGE | app | tier | start_time"
echo "--------------------------------------------------"

# Loop through all running containers
# for id in $(docker ps -aq --filter "label=env=training"); do
for id in $(docker ps -q); do
    # Extract data using Go Templates
    # {{index .Config.Labels "app"}} handles the label metadata
    docker inspect --format \
    '{{.Name}} | {{.Config.Image}} | {{index .Config.Labels "app"}} | {{index .Config.Labels "tier"}} | {{.State.StartedAt}}' \
    $id | sed 's/^\///'
done
