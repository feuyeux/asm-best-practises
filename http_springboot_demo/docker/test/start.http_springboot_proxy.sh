#!/usr/bin/env bash
docker run \
  --rm \
  --name http_proxy \
  -e HTTP_HELLO_HOST=$(ipconfig getifaddr en0) \
  -p 7001:7001 \
  registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_proxy:1.0.0
