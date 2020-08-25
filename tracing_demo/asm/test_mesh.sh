#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
source tracing.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n trace-hello -o jsonpath={.items..metadata.name})
echo "Test access vm ip directly"
VMS=("$VM_PRI_1" "$VM_PRI_2" "$VM_PRI_3")
for vm in "${VMS[@]}"; do
  k exec "$hello1_pod" -c hello-v1-deploy -n trace-hello -- curl -s "$vm":8001/hello/tracing
  echo
done
echo
echo "Test access hello2-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n trace-hello \
-- curl -s hello2-svc.trace-hello.svc.cluster.local:8001/hello/tracing
echo
echo
echo "Test access hello1-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n trace-hello \
-- curl -s hello1-svc.trace-hello.svc.cluster.local:8008/hello/tracing
echo

k exec "$hello1_pod" -c hello-v1-deploy -n trace-hello \
-- curl -s hello3-svc.trace-hello.svc.cluster.local:8001/hello/tracing
echo