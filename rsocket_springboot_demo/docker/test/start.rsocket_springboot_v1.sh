#!/usr/bin/env bash
docker run \
  --rm \
  --name rsocket_v1 \
  -p 8001:9001 \
  -e RSOCKET_HELLO_BACKEND=$(ipconfig getifaddr en0) \
  registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_springboot_v1:1.0.0