#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

echo "1 initialize..."
k delete namespace http-hello >/dev/null 2>&1
m delete namespace http-hello >/dev/null 2>&1
k create ns http-hello
k label ns http-hello istio-injection=enabled

echo "2 setup deployment"
k apply -f data_plane/hello_serviceaccount.yaml
k apply -f data_plane/hello1_deployment.yaml
k apply -f data_plane/hello2_deployment.yaml
k apply -f data_plane/hello3_deployment.yaml

k -n http-hello get sa
echo "waiting for hello1-deploy"
k -n http-hello wait --for=condition=ready pod -l app=hello1-deploy
echo "waiting for hello2-deploy-v1"
k -n http-hello wait --for=condition=ready pod -l app=hello2-deploy-v1
echo "waiting for hello2-deploy-v2"
k -n http-hello wait --for=condition=ready pod -l app=hello2-deploy-v2
echo "waiting for hello2-deploy-v3"
k -n http-hello wait --for=condition=ready pod -l app=hello2-deploy-v3
echo "waiting for hello3-deploy"
k -n http-hello wait --for=condition=ready pod -l app=hello3-deploy
k -n http-hello get po

echo "3 setup service"
k apply -f data_plane/hello1_service.yaml
k apply -f data_plane/hello2_service.yaml
k apply -f data_plane/hello3_service.yaml
