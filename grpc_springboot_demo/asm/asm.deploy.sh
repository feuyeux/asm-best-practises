#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config

echo "4 setup gateway"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  create ns grpc-hello >/dev/null 2>&1

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/grpc_springboot_gateway.yaml

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
  -n grpc-hello \
  get virtualservices

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
  -n grpc-hello \
  get destinationrules
