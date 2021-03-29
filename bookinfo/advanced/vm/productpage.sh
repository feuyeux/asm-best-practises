PRODUCTPAGE_REPO=registry.cn-beijing.aliyuncs.com/asm_repo/examples-bookinfo-productpage-v1:1.16.2
docker run -d --name=productpage -p 9080:9080 $PRODUCTPAGE_REPO
curl localhost:9080 -I