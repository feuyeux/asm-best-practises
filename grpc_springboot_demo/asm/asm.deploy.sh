#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
alias m="kubectl --kubeconfig $MESH_CONFIG"

echo " create ns grpc-hello"
m create ns grpc-hello
sleep 5s
m label ns grpc-hello istio-injection=enabled

echo "4 setup gateway"
m apply -f control_plane/grpc_springboot_gateway.yaml

echo "5 setup virtual service"
m apply -f control_plane/hello1_virtualservice.yaml
m apply -f control_plane/hello2_virtualservice.yaml
m apply -f control_plane/hello3_virtualservice.yaml
m -n grpc-hello get virtualservices

echo "6 setup destination rule"
m apply -f control_plane/hello1_destinationrule.yaml
m apply -f control_plane/hello2_destinationrule.yaml
m apply -f control_plane/hello3_destinationrule.yaml
m -n grpc-hello get destinationrules
