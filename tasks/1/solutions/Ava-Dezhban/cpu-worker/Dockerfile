FROM alpine
LABEL app="cpu-worker" tier="worker" env="training"

# Simulates CPU work by calculating hashes in a loop
CMD ["/bin/sh", "-c", "while true; do echo 'working' | sha256sum; sleep 2; done"] 
