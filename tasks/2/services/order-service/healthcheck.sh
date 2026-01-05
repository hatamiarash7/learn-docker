#!/bin/sh
set -e
curl -sf http://localhost:5000/health >/dev/null || exit 1
exit 0
