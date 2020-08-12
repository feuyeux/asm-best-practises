#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config

####
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello2_serviceentry.yaml
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello2_workloadentry1.yaml
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello2_workloadentry2.yaml
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  apply -f control_plane/hello2_workloadentry3.yaml