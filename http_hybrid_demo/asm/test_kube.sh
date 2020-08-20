#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias s="kubectl --kubeconfig $MESH_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n hybrid-hello -o jsonpath={.items..metadata.name})
echo "1 Test access vm ip directly"
VMS=("$VM_PRI_2" "$VM_PRI_3")
for vm in "${VMS[@]}"; do
  k exec "$hello1_pod" -c hello-v1-deploy -n hybrid-hello -- curl -s "$vm":8001/hello/eric
  echo
done
echo
echo "2 Test access hello2-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n hybrid-hello -- curl -s hello2-svc.hybrid-hello.svc.cluster.local:8001/hello/eric
echo
echo
echo "3 Test access hello1-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n hybrid-hello -- curl -s hello1-svc.hybrid-hello.svc.cluster.local:8003/hello/eric
echo
echo
echo "4 Test route(hello2-svc) in a loop"
for i in {1..5}; do
  resp=$(k exec "$hello1_pod" -c hello-v1-deploy -n hybrid-hello -- curl -s hello1-svc.hybrid-hello.svc.cluster.local:8003/hello/eric)
  echo $i "$resp"
done
