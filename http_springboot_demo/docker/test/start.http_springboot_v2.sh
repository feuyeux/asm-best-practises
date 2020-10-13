#!/usr/bin/env bash
docker run \
  --rm \
  --name http_v2 \
  -p 8001:8001 \
  registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.0
