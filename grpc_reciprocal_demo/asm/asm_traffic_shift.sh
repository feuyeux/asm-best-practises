#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../reciprocal.config
alias m="kubectl --kubeconfig $MESH_CONFIG"
m apply -f control_plane/grpc-reciprocal-hello-all.yaml
