#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..

USER_CONFIG=~/shop_config/ack_bj
MESH_CONFIG=~/shop_config/asm_bj
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

verify_in_loop(){
  for i in {1..5}; do
  echo ">>> test hello1 -> hello2"
  k exec "$hello1_pod" -c hello-v1-deploy -n pod-vm-hello -- curl -s localhost:8001/hello/eric
  echo
  echo ">>> test hello2 directly"
  k exec "$hello1_pod" -c hello-v1-deploy -n pod-vm-hello -- curl -s hello2-svc.pod-vm-hello.svc.cluster.local:8001/hello/eric
  echo
done
}

hello1_pod=$(k get pod -l app=hello1-deploy -n pod-vm-hello -o jsonpath={.items..metadata.name})

echo "1 delete pod and test serviceentry only routes to workloadentry:"
k delete -f yaml/hello2-deploy-v2.yaml
sleep 5s
k get pod -n pod-vm-hello -o wide
verify_in_loop

echo "2 add pod and test serviceentry routes to pod and workloadentry:"
k apply -f yaml/hello2-deploy-v2.yaml
k -n pod-vm-hello wait --for=condition=ready pod -l app=hello2-deploy
k get pod -n pod-vm-hello -o wide
verify_in_loop

echo "3 delete workloadentry and test serviceentry only routes to pod:"
m delete workloadentry vm1 -n pod-vm-hello
sleep 5s
verify_in_loop