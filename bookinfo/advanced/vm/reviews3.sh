REVIEWS_REPO=registry.cn-beijing.aliyuncs.com/asm_repo/examples-bookinfo-reviews-v3:1.16.2
docker run -d --name=eviews-v1 -p 9080:9080 $REVIEWS_REPO
curl localhost:9080 -I