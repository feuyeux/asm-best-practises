#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../tracing.config

alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

k delete svc hello2-svc -n trace-hello >/dev/null 2>&1
m delete namespace trace-hello >/dev/null 2>&1
m create ns trace-hello
m label ns trace-hello istio-injection=enabled

MESH_ID=$(head -n 1 "$MESHID_CONFIG")

aliyun servicemesh AddVmAppToMesh \
  --ServiceMeshId "$MESH_ID" \
  --Namespace trace-hello \
  --ServiceName hello2-svc \
  --Ips "$VM_PRI_1","$VM_PRI_2","$VM_PRI_3" \
  --Ports http:8001 \
  --Labels app=hello-workload
echo "done"

k get svc hello2-svc -n trace-hello -o yaml
echo
m get serviceentry mesh-expansion-hello2-svc -n trace-hello -o yaml
echo
m get workloadentry mesh-expansion-hello2-svc-1 -n trace-hello -o yaml
echo
m get workloadentry mesh-expansion-hello2-svc-2 -n trace-hello -o yaml
echo
m get workloadentry mesh-expansion-hello2-svc-3 -n trace-hello -o yaml
