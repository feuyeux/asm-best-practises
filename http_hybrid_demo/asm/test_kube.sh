#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n hybrid-hello -o jsonpath={.items..metadata.name})
hello2_pod=$(k get pod -l app=hello2-deploy -n hybrid-hello -o jsonpath={.items..metadata.name})
hello2_ip=$(k get pod -l app=hello2-deploy -n hybrid-hello -o jsonpath={.items..status.podIP})

echo "1 Test access vm ip directly"

echo "curl to POD $hello2_ip"
k exec "$hello2_pod" -c hello-v1-deploy -n hybrid-hello -- curl -s localhost:8001/hello/eric
echo
VMS=("$VM_PRI_2" "$VM_PRI_3")
for vm in "${VMS[@]}"; do
  echo "curl to VM $vm"
  k exec "$hello1_pod" -c hello-v1-deploy -n hybrid-hello -- \
    curl -s "$vm":8001/hello/eric
  echo
done
echo
echo "2 Test access hello2-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n hybrid-hello -- \
  curl -s hello2-svc.hybrid-hello.svc.cluster.local:8001/hello/eric
echo
echo
echo "3 Test access hello2-svc in a loop"
for i in {1..6}; do
  k exec "$hello1_pod" -c hello-v1-deploy -n hybrid-hello -- \
    curl -s hello2-svc.hybrid-hello.svc.cluster.local:8001/hello/eric
  echo
done
echo
echo "4 Test route hello1-svc -> hello2-svc "
k exec "$hello1_pod" -c hello-v1-deploy -n hybrid-hello -- \
  curl -s hello1-svc.hybrid-hello.svc.cluster.local:8003/hello/eric
echo
echo
echo "5 Test route hello1-svc -> hello2-svc in a loop"
for i in {1..6}; do
  resp=$(k exec "$hello1_pod" -c hello-v1-deploy -n hybrid-hello -- \
    curl -s hello1-svc.hybrid-hello.svc.cluster.local:8003/hello/eric)
  echo $i "$resp"
done