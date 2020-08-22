#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config

alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

MESH_ID=$(head -n 1 "$MESHID_CONFIG")

m delete namespace hybrid-hello >/dev/null 2>&1

# https://help.aliyun.com/document_detail/178914.html
aliyun servicemesh AddVmAppToMesh \
--ServiceMeshId "$MESH_ID" \
--Namespace hybrid-hello \
--ServiceName hello2-svc \
--Ips "$VM_PRI_2","$VM_PRI_3" \
--Ports http:8001 \
--Labels app=hello2-deploy \
--ServiceAccount hello-sa \
--Force true

echo "done"