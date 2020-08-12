#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
<<<<<<< HEAD
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

echo "setup gateway"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  create ns hello >/dev/null 2>&1

=======

echo "4 setup gateway"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  create ns http-hello >/dev/null 2>&1

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/http_springboot_gateway.yaml

echo "5 setup virtual service"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello1_virtualservice.yaml
>>>>>>> 9cc6f6c8a3798b3ed86027e67f5ade05b6a3ada3
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello2_virtualservice.yaml
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello3_virtualservice.yaml

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n http-hello \
  get virtualservices

#kubectl \
#  --kubeconfig "$MESH_CONFIG" \
#  -n http-hello \
#  get virtualservices.networking.istio.io http-http-hello-vs -o yaml

echo "6 setup destination rule"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello1_destinationrule.yaml
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello2_destinationrule.yaml
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello3_destinationrule.yaml

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n http-hello \
  get destinationrules
