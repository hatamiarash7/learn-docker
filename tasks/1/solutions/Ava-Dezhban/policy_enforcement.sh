# #!/bin/bash

# echo "Searching for containers violating policy (env != training)..."
# echo "------------------------------------------------------------"
# violators=$(docker ps -q --filter "label!=env=training")

# if [ -z "$violators" ]; then
#     echo 'No policy violations found. All containers are compliant.'
# else
#     for id in $violators; do
#         # Get the name of the container for the report
#         name=$(docker inspect --format '{{.Name}}' $id | sed 's/^\///')
        
#         echo "VIOLATION FOUND: Container '$name' is not part of training!"
        
#         # Stop the container
#         echo "Action: Stopping $id..."
#         docker stop $id
#     done
#     echo "------------------------------------------------------------"
#     echo "Policy enforcement complete."
# fi

#!/bin/bash

# 1. Get IDs of all running containers
all_containers=$(docker ps -q)

# 2. Loop through them and check for the label
for cid in $all_containers; do
    # Check if the container has the label env=training
    # Using <no value> check to handle containers that have NO labels at all
    is_training=$(docker inspect --format '{{index .Config.Labels "env"}}' $cid)

    if [ "$is_training" != "training" ]; then
        name=$(docker inspect --format '{{.Name}}' $cid | sed 's/\///')
        echo "Found non-compliant container: $name (ID: $cid)"
        
        # Stop the container
        echo "Action: Stopping $name..."
        docker stop $cid
        echo "------------------------------------------------------------"
    fi
done

echo "Policy enforcement complete."