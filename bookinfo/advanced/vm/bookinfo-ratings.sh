#!/usr/bin/env sh
ACR_REPO=wasm-repo-registry.cn-beijing.cr.aliyuncs.com/bookinfo
RATINGS_REPO=$ACR_REPO/ratings:1.16.2

docker run -d \
    --name=ratings \
    --network=host \
    $RATINGS_REPO
sleep 5
curl localhost:9080/ratings/1 -I
