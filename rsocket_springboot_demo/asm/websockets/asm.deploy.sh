#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../asm.config
alias m="kubectl --kubeconfig $MESH_CONFIG"

echo "4 setup gateway"
m create ns rsocket-ws-hello >/dev/null 2>&1
m apply -f control_plane/rsocket_springboot_gateway.yaml

echo "5 setup destination rule"
m apply -f control_plane/hello1_destinationrule.yaml
m apply -f control_plane/hello2_destinationrule.yaml
m apply -f control_plane/hello3_destinationrule.yaml
m -n rsocket-ws-hello get destinationrules

echo "6 setup virtual service"
m apply -f control_plane/hello1_virtualservice.yaml
m apply -f control_plane/hello2_virtualservice.yaml
m apply -f control_plane/hello3_virtualservice.yaml
m -n rsocket-ws-hello get virtualservices
