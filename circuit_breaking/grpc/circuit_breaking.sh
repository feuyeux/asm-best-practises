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
k delete namespace grpc-circuit-breaking >/dev/null 2>&1
m delete namespace grpc-circuit-breaking >/dev/null 2>&1
k create ns grpc-circuit-breaking
k label ns grpc-circuit-breaking istio-injection=enabled
m create ns grpc-circuit-breaking
m label ns grpc-circuit-breaking istio-injection=enabled

echo "2 setup..."
k apply -f yaml/ack-all.yaml
m apply -f yaml/asm-all.yaml

echo "waiting for hello1-deploy"
k -n grpc-circuit-breaking wait --for=condition=ready pod -l app=hello1-deploy
echo "waiting for hello2-deploy"
k -n grpc-circuit-breaking wait --for=condition=ready pod -l app=hello2-deploy

echo "3 check crd..."
k -n grpc-circuit-breaking get all -n grpc-circuit-breaking
m -n grpc-circuit-breaking get virtualservice,destinationrule -n grpc-circuit-breaking