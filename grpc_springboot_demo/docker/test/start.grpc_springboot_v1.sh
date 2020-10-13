#!/usr/bin/env bash
docker run \
  --rm \
  --name grpc_hello_v1 \
  -e GRPC_HELLO_BACKEND=$(ipconfig getifaddr en0) \
  -p 6001:7001 \
  registry.cn-beijing.aliyuncs.com/asm_repo/grpc_springboot_v1:1.0.0
