#!/usr/bin/env bash

docker run \
--rm \
--name provider2 \
-p 6565:6565 \
feuyeux/grpc_provider_v2:1.0.0