#!/usr/bin/env sh
# only for avp
echo "==== Configure the virtual machine ===="

echo "1 Setup the root certificate|token|cluster.env|Mesh Config"
test -d /opt/asm_vm_proxy/meta || mkdir -p /opt/asm_vm_proxy/meta
cp "${HOME}"/root-cert.pem /opt/asm_vm_proxy/meta/root-cert.pem
cp "${HOME}"/istio-token /opt/asm_vm_proxy/meta/istio-token
cp "${HOME}"/cluster.env /opt/asm_vm_proxy/meta/cluster.env
cp "${HOME}"/mesh.yaml /opt/asm_vm_proxy/meta/
cp "${HOME}"/hosts /opt/asm_vm_proxy/meta/

echo "2 Clean"
rm -f /var/log/istio/*.log
docker stop $(docker ps -a -q) >/dev/null 2>&1
docker rm $(docker ps -a -q) >/dev/null 2>&1
docker rmi -f $(docker images | grep none | awk "{print $3}") >/dev/null 2>&1

echo "3 Pull avp image"
version=1.8.3
IMAGE_REPO=registry.cn-hangzhou.aliyuncs.com/acs/asm-vm-proxy:$version-aliyun
docker pull $IMAGE_REPO

echo "4 Start avp"
docker run -d \
  --name=asm_vm_proxy \
  --network=host \
  --env-file /opt/asm_vm_proxy/asm_vm_proxy.env \
  --cap-add=NET_ADMIN \
  -v /opt/asm_vm_proxy/meta:/opt/asm_vm_proxy/meta \
  -v /var/log/istio:/var/log/istio \
  $IMAGE_REPO

echo "5 Watching"
sleep 3s
tail -n 200 /var/log/istio/vm_proxy.log
sleep 3s
docker exec asm_vm_proxy ps aux
sleep 3s
tail -n 200 -f /var/log/istio/istio.log
