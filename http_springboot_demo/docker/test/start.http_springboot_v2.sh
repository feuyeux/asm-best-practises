#!/usr/bin/env bash
docker run \
--rm \
--name http_v2 \
-p 8001:8001 \
feuyeux/http_springboot_v2:1.0.1