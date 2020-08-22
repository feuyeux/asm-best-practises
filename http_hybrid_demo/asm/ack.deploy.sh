#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

echo "1 initialize..."
k delete namespace hybrid-hello >/dev/null 2>&1
m delete namespace hybrid-hello >/dev/null 2>&1
k create ns hybrid-hello
k label ns hybrid-hello istio-injection=enabled

echo "2 setup kube"
k apply -f data_plane/hello_sa.yaml
k apply -f data_plane/hello1_deployment.yaml
k apply -f data_plane/hello2_deployment.yaml
k apply -f data_plane/hello3_deployment.yaml

echo " waiting for hello1-deploy"
k -n hybrid-hello  wait --for=condition=ready pod -l app=hello1-deploy
echo " waiting for hello2-deploy"
k -n hybrid-hello wait --for=condition=ready pod -l app=hello2-deploy
echo " waiting for hello3-deploy"
k -n hybrid-hello wait --for=condition=ready pod -l app=hello3-deploy

k apply -f data_plane/hello1_service.yaml
k apply -f data_plane/hello2_service.yaml
k apply -f data_plane/hello3_service.yaml