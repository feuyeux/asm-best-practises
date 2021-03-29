#!/usr/bin/env sh
pull_tag_push() {
    FROM=$1
    TO=$2
    # docker pull ${FROM}
    docker tag ${FROM} ${TO}
    docker push ${TO}
}
ACR_REPO=wasm-repo-registry.cn-beijing.cr.aliyuncs.com/bookinfo

pull_tag_push docker.io/istio/examples-bookinfo-productpage-v1:1.16.2 $ACR_REPO/productpage:1.16.2
pull_tag_push docker.io/istio/examples-bookinfo-details-v1:1.16.2 $ACR_REPO/details:1.16.2
pull_tag_push docker.io/istio/examples-bookinfo-ratings-v1:1.16.2 $ACR_REPO/ratings:1.16.2
pull_tag_push docker.io/istio/examples-bookinfo-reviews-v1:1.16.2 $ACR_REPO/reviews-v1:1.16.2
pull_tag_push docker.io/istio/examples-bookinfo-reviews-v2:1.16.2 $ACR_REPO/reviews-v2:1.16.2
pull_tag_push docker.io/istio/examples-bookinfo-reviews-v3:1.16.2 $ACR_REPO/reviews-v3:1.16.2
