#!/usr/bin/env sh
ACR_REPO=wasm-repo-registry.cn-beijing.cr.aliyuncs.com/bookinfo
DETAILS_REPO=$ACR_REPO/details:1.16.2

docker run -d \
    --name=details \
    --network=host \
    $DETAILS_REPO
sleep 5
curl localhost:9080/details/1 -I
