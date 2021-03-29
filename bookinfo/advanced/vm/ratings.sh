RATINGS_REPO=registry.cn-beijing.aliyuncs.com/asm_repo/examples-bookinfo-ratings-v1:1.16.2
docker run -d --name=ratings -p 9080:9080 $RATINGS_REPO
curl localhost:9080 -I