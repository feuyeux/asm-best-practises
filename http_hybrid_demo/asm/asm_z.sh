#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config
alias m="kubectl --kubeconfig $MESH_CONFIG"
m apply -f control_plane/hello1_destinationrule.yaml
m apply -f control_plane/hybird_gateway.yaml