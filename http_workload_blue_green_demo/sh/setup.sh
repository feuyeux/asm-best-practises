#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
source blue-green.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

echo "1 init..."
k delete namespace hello-grouping
m delete namespace hello-grouping
k create ns hello-grouping
k label ns hello-grouping istio-injection=enabled
m create ns hello-grouping
m label ns hello-grouping istio-injection=enabled

echo "2 setup hello1 pod"
k apply -f yaml/hello1-deploy.yaml
k -n hello-grouping wait --for=condition=ready pod -l app=hello1-deploy

echo "3 setup hello2 ServiceEntry/WorkloadEntry"
MESH_ID=$(head -n 1 "$MESHID_CONFIG")
aliyun servicemesh AddVmAppToMesh \
  --ServiceMeshId "$MESH_ID" \
  --Namespace hello-grouping \
  --ServiceName hello2-svc \
  --Ips "$VM_PRI_1","$VM_PRI_2","$VM_PRI_3","$VM_PRI_4" \
  --Ports http:8001 \
  --Labels app=http-workload
echo "done"

echo "4 setup hello2 VirtualService/DestinationRule"
m apply -f yaml/hello2-dr.yaml
m apply -f yaml/hello2-vs.yaml

echo "5 verify kube crd"
k get svc -n hello-grouping -o wide
k get pod -n hello-grouping -o wide

echo "6 verify mesh crd"
m get serviceentry,workloadentry -n hello-grouping -o wide
m get VirtualService,DestinationRule -n hello-grouping -o wide
