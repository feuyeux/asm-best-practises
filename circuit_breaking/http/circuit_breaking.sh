#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source circuit_breaking.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

k version --short

echo "1 initialize..."
k delete namespace http-circuit-breaking >/dev/null 2>&1
k create ns http-circuit-breaking
k label ns http-circuit-breaking istio-injection=enabled

m delete namespace http-circuit-breaking >/dev/null 2>&1
m create ns http-circuit-breaking
m label ns http-circuit-breaking istio-injection=enabled

echo "2 setup..."
k apply -f yaml/ack-all.yaml
m apply -f yaml/asm-all.yaml
k apply -f yaml/fortio-deploy.yaml

echo "waiting for hello1-deploy"
k -n http-circuit-breaking wait --for=condition=ready pod -l app=hello1-deploy
echo "waiting for hello2-deploy"
k -n http-circuit-breaking wait --for=condition=ready pod -l app=hello1-deploy

echo "3 check crd..."
k -n http-circuit-breaking get all -n http-circuit-breaking
m -n http-circuit-breaking get virtualservice,destinationrule -n http-circuit-breaking

echo "4 verify route..."
hello1_pod=$(k get pod -l app=hello1-deploy -n http-circuit-breaking -o jsonpath={.items..metadata.name})
k exec "$hello1_pod" -c hello-v2-deploy -n http-circuit-breaking -- curl -s hello2-svc.http-circuit-breaking.svc.cluster.local:8001/hello/eric
echo
k exec "$hello1_pod" -c hello-v2-deploy -n http-circuit-breaking -- curl -s localhost:8001/hello/eric
echo
