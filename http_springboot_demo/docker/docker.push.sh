#!/usr/bin/env bash
echo "start to push images"
docker push registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_proxy:1.0.1
docker push registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.1
docker push registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.1
docker push registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.1
# https://cr.console.aliyun.com/cn-beijing/instances/repositories