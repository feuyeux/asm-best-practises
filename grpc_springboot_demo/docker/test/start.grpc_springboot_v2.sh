#!/usr/bin/env bash
docker run \
--rm \
--name grpc_hello_v2 \
-p 7001:7001 \
registry.cn-beijing.aliyuncs.com/asm_repo/grpc_springboot_v2:1.0.0
