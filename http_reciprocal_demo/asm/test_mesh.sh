#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../reciprocal.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n http-reciprocal-hello -o jsonpath={.items..metadata.name})
echo "1 Test access vm ip directly"
VMS=("$VM_PRI_1" "$VM_PRI_2" "$VM_PRI_3")
for vm in "${VMS[@]}"; do
  if [ "$vm" ]; then
    if [ ! -s "$vm" ]; then
      k exec "$hello1_pod" -c hello-v1-deploy -n http-reciprocal-hello -- curl -s "$vm":8001/hello/eric
      echo
    fi
  fi
done

echo
echo "2 Test access hello2-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n http-reciprocal-hello \
  -- curl -s hello2-svc.http-reciprocal-hello.svc.cluster.local:8001/hello/eric
echo
echo
echo "3 Test access hello1-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n http-reciprocal-hello \
  -- curl -s hello1-svc.http-reciprocal-hello.svc.cluster.local:8004/hello/eric
echo
