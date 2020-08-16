#!/usr/bin/env bash
docker run \
  --rm \
  --name rsocket_v2 \
  -p 9001:9001 \
  registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_springboot_v2:1.0.0