#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n hello -o jsonpath={.items..metadata.name})
echo "hello1_pod=$hello1_pod"
hello1_pod1=$(k get pod -l app=hello1-deploy -n hello -o jsonpath='{.items[0].metadata.name}')
hello1_pod2=$(k get pod -l app=hello1-deploy -n hello -o jsonpath='{.items[1].metadata.name}')
echo "hello1_pod1=$hello1_pod1"
echo "hello1_pod2=$hello1_pod2"
# shellcheck disable=SC2086
k exec $hello1_pod -c hello-v1-deploy -n hello -- netstat -plant | grep java
k exec "$hello1_pod" -c hello-v1-deploy -n hello -- curl -s localhost:8001/hello/feuyeux
k exec "$hello1_pod" -c hello-v1-deploy -n hello -- curl -s hello1-svc.hello.svc.cluster.local:8001/hello/feuyeux

hello2_pod=$(k get pod -l app=hello2-deploy -n hello -o jsonpath={.items..metadata.name})
echo "hello2_pod=$hello2_pod"

hello2_pod1=$(k get pod -l app=hello2-deploy -n hello -o jsonpath='{.items[0].metadata.name}')
hello2_pod2=$(k get pod -l app=hello2-deploy -n hello -o jsonpath='{.items[1].metadata.name}')
hello2_pod3=$(k get pod -l app=hello2-deploy -n hello -o jsonpath='{.items[2].metadata.name}')

k exec "$hello2_pod1" -c hello-v1-deploy -n hello -- curl -s hello3-svc.hello.svc.cluster.local:8001/hello/feuyeux

k exec "$hello2_pod1" -c hello-v1-deploy -n hello -- curl -s localhost:8001/hello/feuyeux
k exec "$hello2_pod2" -c hello-v2-deploy -n hello -- curl -s localhost:8001/hello/feuyeux
k exec "$hello2_pod3" -c hello-v3-deploy -n hello -- curl -s localhost:8001/hello/feuyeux
