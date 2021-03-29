#!/usr/bin/env bash
export YOUR_REPO=feuyeux
docker run \
  --rm \
  --name http_v1 \
  -p 8001:8001 \
  ${YOUR_REPO}/http_springboot_v1:1.0.0
