#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source hybrid.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias s="kubectl --kubeconfig $MESH_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n external-hello -o jsonpath={.items..metadata.name})
echo "Test access vm ip directly"
VMS=("$VM_PRI_1" "$VM_PRI_2" "$VM_PRI_3")
for vm in "${VMS[@]}"; do
  k exec "$hello1_pod" -c hello-v1-deploy -n external-hello -- curl -s "$vm":8001/hello/eric
  echo
done
echo
echo "Test access hello2-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n external-hello -- curl -sv hello2-svc.external-hello.svc.cluster.local:8001/hello/eric
echo
echo
echo "Test access hello1-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n external-hello -- curl -s hello1-svc.external-hello.svc.cluster.local:8002/hello/eric
echo
echo
echo "Test route(hello2-svc) in a loop"
for i in {1..10}; do
  resp=$(k exec "$hello1_pod" -c hello-v1-deploy -n external-hello -- curl -s hello1-svc.external-hello.svc.cluster.local:8002/hello/eric)
  echo $i "$resp"
done
