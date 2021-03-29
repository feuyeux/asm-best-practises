#!/usr/bin/env sh
ACR_REPO=wasm-repo-registry.cn-beijing.cr.aliyuncs.com/bookinfo
PRODUCTPAGE_REPO=$ACR_REPO/productpage:1.16.2

docker run -d \
    --name=productpage \
    -e SERVICES_DOMAIN=bookinfo \
    --network=host \
    $PRODUCTPAGE_REPO
sleep 5
curl localhost:9080/productpage -I
