#!/usr/bin/env bash
set -euo pipefail

URL=${1:-http://localhost:8080}
NAME=${2:-World}

echo "Checking $URL/hello/$NAME"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL/hello/$NAME")
if [ "$HTTP_CODE" != "200" ]; then
  echo "Unexpected http code: $HTTP_CODE" >&2
  exit 2
fi
BODY=$(curl -s "$URL/hello/$NAME")
if [[ $BODY != *"Hello, $NAME"* ]]; then
  echo "Unexpected body: $BODY" >&2
  exit 3
fi

echo "smoke-hello ok"
