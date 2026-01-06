FROM alpine
RUN apk add --no-cache python3

LABEL app=log-producer
LABEL tier=backend
LABEL env=training

COPY logger.py /app/logger.py

CMD ["python3", "/app/logger.py"]