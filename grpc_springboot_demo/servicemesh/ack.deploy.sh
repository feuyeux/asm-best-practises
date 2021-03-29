#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

# ingressgateway[7001] -> hello1-svc[7001] -> hello2-svc[7001] -> hello3-svc[7001]
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

echo "1 initialize..."

echo " delete ns grpc-hello for cluster"
k delete namespace grpc-hello >/dev/null 2>&1
sleep 10s
echo " delete ns grpc-hello for mesh"
m delete namespace grpc-hello >/dev/null 2>&1
sleep 5s

echo " create ns grpc-hello"
k create ns grpc-hello
sleep 5s
k label ns grpc-hello istio-injection=enabled

echo "2 setup deployment"
k apply -f data_plane/hello_serviceaccount.yaml
k apply -f data_plane/hello1_deployment.yaml
k apply -f data_plane/hello2_deployment.yaml
k apply -f data_plane/hello3_deployment.yaml
k -n grpc-hello get sa

echo "waiting for hello1-deploy"
k -n grpc-hello wait --for=condition=ready pod -l app=hello1-deploy

echo "waiting for hello2-deploy"
k -n grpc-hello wait --for=condition=ready pod -l app=hello2-deploy

echo "waiting for hello3-deploy"
k -n grpc-hello wait --for=condition=ready pod -l app=hello3-deploy
k -n grpc-hello get po

echo "3 setup service"
k apply -f data_plane/hello1_service.yaml
k apply -f data_plane/hello2_service.yaml
k apply -f data_plane/hello3_service.yaml
