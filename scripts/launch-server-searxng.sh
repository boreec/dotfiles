#!/bin/sh
# run a local searxng server
PORT=6060
CONTAINER_NAME="local_searxng"

if [ ! "$(docker ps -a | grep $CONTAINER_NAME)" ] > /dev/null; then
  docker pull searxng/searxng
  docker run --rm \
    -d -p ${PORT}:8080 \
    -v "$HOME/searxng:/etc/searxng" \
    -e "BASE_URL=http://localhost:$PORT" \
    -e "INSTANCE_NAME=searxng-local" \
    --name ${CONTAINER_NAME} \
    searxng/searxng
fi
