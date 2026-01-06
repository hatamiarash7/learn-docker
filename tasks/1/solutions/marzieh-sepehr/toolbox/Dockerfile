FROM python:3.13-slim

LABEL app=toolbox
LABEL tier=utility
LABEL env=training

# Copy script to specified path
COPY info.py /opt/info.py

# Make executable
RUN chmod +x /opt/info.py

# Set working directory
WORKDIR /opt

# Default command: python3 (as per task requirements)
CMD ["python3"]