#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

echo "setup deployment"
kubectl \
  --kubeconfig ~/shop/bj_config \
  apply -f data_plane/http_springboot_deployment.yaml

kubectl \
  --kubeconfig ~/shop/bj_config \
  get sa | grep http-hello

echo "setup service"
kubectl \
  --kubeconfig ~/shop/bj_config \
  apply -f data_plane/http_springboot_service.yaml

kubectl \
  --kubeconfig ~/shop/bj_config \
  get po

#echo "setup ingress gateway"
#CID=
#sed "s#{CLUSTER_ID}#$CID#g" data_plane/http_springboot_ingressgateway.yaml.template >/tmp/http_springboot_ingressgateway.yaml
#kubectl \
#  --kubeconfig ~/shop/zjk_asm_config \
#  apply -f /tmp/http_springboot_ingressgateway.yaml

echo "setup gateway"
kubectl \
  --kubeconfig ~/shop/zjk_asm_config \
  apply -f control_plane/http_springboot_gateway.yaml

echo "setup virtual service"
kubectl \
  --kubeconfig ~/shop/zjk_asm_config \
  apply -f control_plane/http_springboot_virtualservice.yaml

kubectl \
  --kubeconfig ~/shop/zjk_asm_config \
  get virtualservices

kubectl \
  --kubeconfig ~/shop/zjk_asm_config \
  get virtualservices.networking.istio.io http-hello-vs -o yaml

echo "setup destination rule"
kubectl \
  --kubeconfig ~/shop/zjk_asm_config \
  apply -f control_plane/http_springboot_destinationrule.yaml

kubectl \
  --kubeconfig ~/shop/zjk_asm_config \
  get destinationrules
