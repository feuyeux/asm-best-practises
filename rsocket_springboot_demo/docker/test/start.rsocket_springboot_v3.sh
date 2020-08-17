#!/usr/bin/env bash

if [ "$1" = tcp ]; then
  echo "MODE:TCP"
  docker run \
    --rm \
    --name rsocket_v3 \
    -p 9001:9001 \
    registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_tcp_springboot_v3:1.0.0
fi

if [ "$1" = ws ]; then
  echo "MODE:WEBSOCKETS"
  docker run \
    --rm \
    --name rsocket_v3 \
    -p 9001:9001 \
    registry.cn-beijing.aliyuncs.com/asm_repo/rsocket_ws_springboot_v3:1.0.0
fi
