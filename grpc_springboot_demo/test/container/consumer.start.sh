#!/usr/bin/env bash
docker run \
--rm \
--name consumer \
-e GRPC_PROVIDER_HOST=$(ipconfig getifaddr en0) \
-p 9001:9001 \
feuyeux/grpc_consumer