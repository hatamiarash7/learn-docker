FROM alpine


RUN apk add --no-cache python3

LABEL app=cpu-worker
LABEL tier=worker
LABEL env=training

COPY worker.py /app/worker.py

CMD ["python3", "/app/worker.py"]