#!/usr/bin/env bash
docker run \
--rm \
--name http_v3 \
-p 8001:8001 \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.0