#!/usr/bin/env bash
docker run \
--rm \
--name http_v1 \
-p 8001:8001 \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.0