#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
source blue-green.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n vm-blue-green -o jsonpath={.items..metadata.name})

VMS=("$VM_PUB_1" "$VM_PUB_2" "$VM_PUB_3" "$VM_PUB_4")
for vm in "${VMS[@]}"; do
  echo "Test http://$vm:8001/hello/eric"
  curl "http://$vm:8001/hello/eric"
  echo
done
echo
VMS=("$VM_PRI_1" "$VM_PRI_2" "$VM_PRI_3" "$VM_PRI_4")
for vm in "${VMS[@]}"; do
  echo "Test http://$vm:8001/hello/eric"
  k exec "$hello1_pod" -c hello-v1-deploy -n vm-blue-green -- \
    curl -s http://"$vm":8001/hello/eric
  echo
done
