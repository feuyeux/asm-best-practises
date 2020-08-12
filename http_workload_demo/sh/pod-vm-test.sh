#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

USER_CONFIG=~/shop_config/ack_bj
VM_PRI_1=192.168.0.170
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n pod-vm-hello -o jsonpath={.items..metadata.name})

k exec "$hello1_pod" -c hello-v1-deploy -n pod-vm-hello -- curl -s $VM_PRI_1:8001/hello/eric
echo

for i in {1..5}; do
  echo ">>> test hello1 -> hello2"
  k exec "$hello1_pod" -c hello-v1-deploy -n pod-vm-hello -- curl -s localhost:8001/hello/eric
  echo
  echo ">>> test hello2 directly"
  k exec "$hello1_pod" -c hello-v1-deploy -n pod-vm-hello -- curl -s hello2-svc.pod-vm-hello.svc.cluster.local:8001/hello/eric
  echo
done