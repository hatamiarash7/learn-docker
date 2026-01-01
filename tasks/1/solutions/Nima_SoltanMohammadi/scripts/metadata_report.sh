#!/bin/bash

echo "CONTAINER_NAME | IMAGE | app | tier | start_time"
echo "-----------------------------------------------------------"

for container in $(docker ps -q); do
    name=$(docker inspect --format '{{.Name}}' $container | sed 's/\///')
    image=$(docker inspect --format '{{.Config.Image}}' $container)
    app=$(docker inspect --format '{{index .Config.Labels "app"}}' $container)
    tier=$(docker inspect --format '{{index .Config.Labels "tier"}}' $container)
    start_time=$(docker inspect --format '{{.State.StartedAt}}' $container)
    
    echo "$name | $image | $app | $tier | $start_time"
done
