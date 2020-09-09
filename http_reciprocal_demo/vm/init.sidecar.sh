#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
source reciprocal.config

VMS=("$VM_PUB_1" "$VM_PUB_2" "$VM_PUB_3")

MESH_ID=$(head -n 1 "$MESHID_CONFIG")
echo "MESH_ID=$MESH_ID"
aliyun servicemesh GetVmMeta \
  --ServiceMeshId "$MESH_ID" \
  --Namespace http-reciprocal-hello \
  --ServiceAccount http-sa \
  | jq '.VmMetaInfo' >asm_vm_proxy_meta.json

for vm in "${VMS[@]}"; do
  scp asm_vm_proxy_meta.json root@"$vm":/root
done
