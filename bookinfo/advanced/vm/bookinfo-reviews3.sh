#!/usr/bin/env sh
ACR_REPO=wasm-repo-registry.cn-beijing.cr.aliyuncs.com/bookinfo
REVIEWS_REPO=$ACR_REPO/reviews-v3:1.16.2

docker run -d \
    --name=reviews3 \
    -e SERVICES_DOMAIN=bookinfo \
    --network=host \
    $REVIEWS_REPO
sleep 5
curl localhost:9080/reviews/1 -I
