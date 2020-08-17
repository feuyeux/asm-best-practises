#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

echo "4 setup gateway"
m create ns rsocket-ws-hello >/dev/null 2>&1
m apply -f control_plane/rsocket_springboot_gateway.yaml

echo "5 setup virtual service"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello1_virtualservice.yaml
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello2_virtualservice.yaml
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello3_virtualservice.yaml

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n rsocket-ws-hello \
  get virtualservices

#kubectl \
#  --kubeconfig "$MESH_CONFIG" \
#  -n rsocket-ws-hello \
#  get virtualservices.networking.istio.io rsocket-rsocket-ws-hello-vs -o yaml

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
  -n rsocket-ws-hello \
  get destinationrules
