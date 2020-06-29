#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

MESH_CONFIG=~/shop_config/bj_mesh_config
USER_CONFIG=~/shop_config/bj_config

echo "initialize..."
kubectl \
  --kubeconfig "$USER_CONFIG" \
  delete namespace hello >/dev/null 2>&1

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  delete namespace hello >/dev/null 2>&1

kubectl \
  --kubeconfig "$USER_CONFIG" \
  create ns hello

kubectl \
  --kubeconfig "$USER_CONFIG" \
  label ns hello istio-injection=enabled
  
echo "setup deployment"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n hello \
  apply -f data_plane/http_springboot_deployment.yaml

kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n hello \
  get sa | grep http-hello

echo "setup service"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n hello \
  apply -f data_plane/http_springboot_service.yaml

kubectl \
  --kubeconfig "$USER_CONFIG" \
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
  --kubeconfig "$MESH_CONFIG" \
  create ns hello
  
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n hello \
  apply -f control_plane/http_springboot_gateway.yaml

echo "setup virtual service"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n hello \
  apply -f control_plane/http_springboot_virtualservice.yaml

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n hello \
  get virtualservices

#kubectl \
#  --kubeconfig "$MESH_CONFIG" \
#  -n hello \
#  get virtualservices.networking.istio.io http-hello-vs -o yaml

echo "setup destination rule"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n hello \
  apply -f control_plane/http_springboot_destinationrule.yaml

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n hello \
  get destinationrules
