#!/usr/bin/env bash
docker run \
--rm \
--name http_v3_proxy \
-e HTTP_HELLO_BACKEND=$(ipconfig getifaddr en0) \
-p 7001:8001 \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.0