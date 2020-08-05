#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config

alias s="kubectl --kubeconfig $MESH_CONFIG"

s apply -f control_plane/hello2_virtualservice.yaml
s apply -f control_plane/hello2_destinationrule.yaml