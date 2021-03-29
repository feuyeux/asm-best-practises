#!/usr/bin/env sh
region=cn-beijing
version=1.8.3
IMAGE_REPO=registry.${region}.aliyuncs.com/acs/asm-vm-proxy:${version}-aliyun
docker pull $IMAGE_REPO
#
docker run -d \
  --name=avp \
  --network=host \
  --restart=always \
  --env-file /opt/avp/avp.env \
  --cap-add=NET_ADMIN \
  $IMAGE_REPO
sleep 5s
docker logs -f avp
