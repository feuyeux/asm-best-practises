#!/usr/bin/env bash
export LOCAL=$(ipconfig getifaddr en0)
echo "LOCAL=${LOCAL}"

docker rm consumer
docker run --name consumer -e GRPC_PROVIDER_HOST=${LOCAL} -p 9001:9001 feuyeux/grpc_consumer

curl -i localhost:9001/bye