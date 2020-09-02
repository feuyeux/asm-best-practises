#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../reciprocal.config

alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

k delete svc hello2-svc -n http-reciprocal-hello >/dev/null 2>&1
m delete namespace http-reciprocal-hello >/dev/null 2>&1
m create ns http-reciprocal-hello
m label ns http-reciprocal-hello istio-injection=enabled

MESH_ID=$(head -n 1 "$MESHID_CONFIG")
echo "MESH_ID=$MESH_ID"
aliyun servicemesh AddVmAppToMesh \
  --ServiceMeshId "$MESH_ID" \
  --Namespace http-reciprocal-hello \
  --ServiceName hello2-svc \
  --Ips "$VM_PRI_1","$VM_PRI_2","$VM_PRI_3" \
  --Ports http:8001 \
  --Labels app=hello-workload
echo "done"

k get svc hello2-svc -n http-reciprocal-hello -o yaml
echo
m get serviceentry mesh-expansion-hello2-svc -n http-reciprocal-hello -o yaml
echo
m get workloadentry mesh-expansion-hello2-svc-1 -n http-reciprocal-hello -o yaml
echo
m get workloadentry mesh-expansion-hello2-svc-2 -n http-reciprocal-hello -o yaml
echo
m get workloadentry mesh-expansion-hello2-svc-3 -n http-reciprocal-hello -o yaml
