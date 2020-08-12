#!/usr/bin/env bash
docker run \
--rm \
--name http_v3_proxy \
-e HTTP_HELLO_BACKEND=$(ipconfig getifaddr en0) \
-p 7001:8001 \
<<<<<<< HEAD
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.0
=======
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.1
>>>>>>> 9cc6f6c8a3798b3ed86027e67f5ade05b6a3ada3
