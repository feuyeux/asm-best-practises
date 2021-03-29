#!/usr/bin/env bash
echo "start to push images"
YOUR_REPO=feuyeux

if [ "" = "$1" ]; then
  tag=1.0.0
else
  tag=$1
fi
echo "tag=$tag"
#sleep 5
echo "pushing ${YOUR_REPO}/http_springboot_v1:$tag"
docker push ${YOUR_REPO}/http_springboot_v1:$tag
echo "pushing ${YOUR_REPO}/http_springboot_v2:$tag"
docker push ${YOUR_REPO}/http_springboot_v2:$tag
echo "pushing ${YOUR_REPO}/http_springboot_v3:$tag"
docker push ${YOUR_REPO}/http_springboot_v3:$tag
