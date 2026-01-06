# Log Producer Image

## Labels
- `app=log-producer`
- `tier=backend`
- `env=training`

## Build
```bash
docker build -t log-producer:1.0 .
docker tag log-producer:1.0 log-producer:stable
```

## Test
```bash

docker run -d --name test-producer log-producer:1.0
docker logs -f test-producer
```

## output

```bash

[INFO] producer alive 2026-01-04 11:45:13
[INFO] producer alive 2026-01-04 11:45:16
[INFO] producer alive 2026-01-04 11:45:19
[INFO] producer alive 2026-01-04 11:45:22

```


