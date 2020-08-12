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

k delete namespace pod-vm-hello
m delete namespace pod-vm-hello
k create ns pod-vm-hello
k label ns pod-vm-hello istio-injection=enabled

k apply -f yaml/hello1-deploy.yaml
k -n pod-vm-hello wait --for=condition=ready pod -l app=hello1-deploy
k apply -f yaml/hello2-deploy-v2.yaml
k -n pod-vm-hello wait --for=condition=ready pod -l app=hello2-deploy

k apply -f yaml/hello2-svc.yaml

hello1_pod=$(k get pod -l app=hello1-deploy -n pod-vm-hello -o jsonpath={.items..metadata.name})

echo "Check traffic from hello1 pod($hello1_pod) localhost:"
k exec "$hello1_pod" -c hello-v1-deploy -n pod-vm-hello -- curl -s localhost:8001/hello/eric

m create ns pod-vm-hello
m apply -f yaml/vm-meshify.yaml

echo "Verify"
k get svc -n pod-vm-hello -o wide
k get pod -n pod-vm-hello -o wide

m get serviceentry -n pod-vm-hello -o wide
m get workloadentry -n pod-vm-hello -o wide