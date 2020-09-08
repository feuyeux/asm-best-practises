#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

echo "4 setup gateway"
m create ns http-hello >/dev/null 2>&1
m apply -f control_plane/http_springboot_gateway.yaml
m -n http-hello get gateway

echo "5 setup virtual service"
m apply -f control_plane/hello1_virtualservice.yaml
m apply -f control_plane/hello2_virtualservice.yaml
m apply -f control_plane/hello3_virtualservice.yaml
m -n http-hello get virtualservices

echo "6 setup destination rule"
m apply -f control_plane/hello1_destinationrule.yaml
m apply -f control_plane/hello2_destinationrule.yaml
m apply -f control_plane/hello3_destinationrule.yaml
m -n http-hello get destinationrules