#!/usr/bin/env bash
echo "start to push images"
docker push registry.cn-beijing.aliyuncs.com/asm_repo/grpc_springboot_v1:1.0.0
docker push registry.cn-beijing.aliyuncs.com/asm_repo/grpc_springboot_v2:1.0.0
docker push registry.cn-beijing.aliyuncs.com/asm_repo/grpc_springboot_v3:1.0.0