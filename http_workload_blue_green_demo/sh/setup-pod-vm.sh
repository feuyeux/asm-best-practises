#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
source blue-green.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

k delete namespace vm-blue-green
m delete namespace vm-blue-green
k create ns vm-blue-green
k label ns vm-blue-green istio-injection=enabled

k apply -f yaml/hello1-deploy.yaml
k -n vm-blue-green wait --for=condition=ready pod -l app=hello1-deploy
k apply -f yaml/hello2-svc.yaml

hello1_pod=$(k get pod -l app=hello1-deploy -n vm-blue-green -o jsonpath={.items..metadata.name})

echo "Check traffic from hello1 pod($hello1_pod) localhost:"
k exec "$hello1_pod" -c hello-v1-deploy -n vm-blue-green -- curl -s localhost:8001/hello/eric

echo "Verify kube crd"
k get svc -n vm-blue-green -o wide
k get pod -n vm-blue-green -o wide

m create ns vm-blue-green
m apply -f yaml/vm-meshify.yaml

echo "Verify mesh crd"
m get serviceentry -n vm-blue-green -o wide
m get serviceentry -n vm-blue-green -o wide
m get serviceentry -n vm-blue-green -o wide