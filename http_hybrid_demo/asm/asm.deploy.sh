#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config

alias k="kubectl --kubeconfig $USER_CONFIG"
alias s="kubectl --kubeconfig $MESH_CONFIG"

s delete namespace hybrid-hello

MESH_ID=c9e8589cc0afa430c80bc1541b6d61f0f

aliyun servicemesh AddVmAppToMesh \
--ServiceMeshId $MESH_ID \
--Namespace hybrid-hello \
--ServiceName hello2-svc \
--Ips "$VM_PRI_1","$VM_PRI_2","$VM_PRI_3" \
--Ports http:8001 \
--Labels app=hello-workload
echo "done"

k get svc hello2-svc -n hybrid-hello -o yaml
echo
s get serviceentry mesh-expansion-hello2-svc -n hybrid-hello -o yaml
echo
s get workloadentry mesh-expansion-hello2-svc-1 -n hybrid-hello -o yaml
echo
s get workloadentry mesh-expansion-hello2-svc-2 -n hybrid-hello -o yaml
echo
s get workloadentry mesh-expansion-hello2-svc-3 -n hybrid-hello -o yaml