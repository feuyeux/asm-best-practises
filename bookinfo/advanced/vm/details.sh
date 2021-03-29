DETAILS_REPO=registry.cn-beijing.aliyuncs.com/asm_repo/examples-bookinfo-details-v1:1.16.2
docker run -d --name=details -p 9080:9080 $DETAILS_REPO
curl localhost:9080 -I