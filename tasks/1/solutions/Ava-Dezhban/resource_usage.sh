#!/bin/bash

# Header
echo "NAME | CPU% | MEM%"
echo "--------------------"
docker stats --no-stream --format "{{.Name}} | {{.CPUPerc}} | {{.MemPerc}}"
