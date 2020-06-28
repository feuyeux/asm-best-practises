#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

kubectl \
  --kubeconfig "$HOME"/shop_config/bj_mesh_config \
  create namespace hello

kubectl \
  --kubeconfig "$HOME"/shop_config/bj_mesh_config \
  label namespace hello istio-injection=enabled

echo "setup deployment"
kubectl \
  --kubeconfig "$HOME"/shop_config/bj_config \
  -n hello \
  apply -f data_plane/http_springboot_deployment.yaml

#kubectl \
#  --kubeconfig "$HOME"/shop_config/bj_config \
#  -n hello \
#  get sa | grep http-hello

echo "setup service"
kubectl \
  --kubeconfig "$HOME"/shop_config/bj_config \
  -n hello \
  apply -f data_plane/http_springboot_service.yaml

kubectl \
  --kubeconfig "$HOME"/shop_config/bj_config \
  -n hello \
  get po

#echo "setup ingress gateway"
#CID=
#sed "s#{CLUSTER_ID}#$CID#g" data_plane/http_springboot_ingressgateway.yaml.template >/tmp/http_springboot_ingressgateway.yaml
#kubectl \
#  --kubeconfig $HOME/shop_config/bj_mesh_config \
#  -n hello \
#  apply -f /tmp/http_springboot_ingressgateway.yaml

echo "setup gateway"
kubectl \
  --kubeconfig "$HOME"/shop_config/bj_mesh_config \
  -n hello \
  apply -f control_plane/http_springboot_gateway.yaml

echo "setup virtual service"
kubectl \
  --kubeconfig "$HOME"/shop_config/bj_mesh_config \
  -n hello \
  apply -f control_plane/http_springboot_virtualservice.yaml

kubectl \
  --kubeconfig "$HOME"/shop_config/bj_mesh_config \
  -n hello \
  get virtualservices

#kubectl \
#  --kubeconfig "$HOME"/shop_config/bj_mesh_config \
#  -n hello \
#  get virtualservices.networking.istio.io http-hello-vs -o yaml

echo "setup destination rule"
kubectl \
  --kubeconfig "$HOME"/shop_config/bj_mesh_config \
  -n hello \
  apply -f control_plane/http_springboot_destinationrule.yaml

kubectl \
  --kubeconfig "$HOME"/shop_config/bj_mesh_config \
  -n hello \
  get destinationrules
