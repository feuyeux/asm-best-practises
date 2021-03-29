#!/usr/bin/env bash
export YOUR_REPO=feuyeux
docker run \
  --rm \
  --name http_v3 \
  -p 8001:8001 \
  ${YOUR_REPO}/http_springboot_v3:1.0.0
