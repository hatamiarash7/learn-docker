FROM alpine
LABEL app="log-producer" tier="backend" env="training"

# Prints a log line every 3 seconds
CMD ["/bin/sh", "-c", "while true; do echo \"[INFO] producer alive $(date)\"; sleep 3; done"]
