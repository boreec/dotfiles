#!/bin/sh
# run a local searxng server
PORT=6060
docker pull searxng/searxng
docker run --rm \
  -d -p ${PORT}:8080 \
  -v "${PWD}/searxng:/etc/searxng" \
  -e "BASE_URL=http://localhost:$PORT" \
  -e "INSTANCE_NAME=searxng-local" \
  searxng/searxng
