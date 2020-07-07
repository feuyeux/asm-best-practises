#!/usr/bin/env bash
docker run \
--rm \
--name http_v3 \
-p 8001:8001 \
feuyeux/http_springboot_v3:1.0.1