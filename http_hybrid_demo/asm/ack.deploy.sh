#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config

echo "1 initialize..."
kubectl \
  --kubeconfig "$USER_CONFIG" \
  delete namespace hybrid-hello >/dev/null 2>&1

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  delete namespace hybrid-hello >/dev/null 2>&1

kubectl \
  --kubeconfig "$USER_CONFIG" \
  create ns hybrid-hello

kubectl \
  --kubeconfig "$USER_CONFIG" \
  label ns hybrid-hello istio-injection=enabled
  
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello_serviceaccount.yaml

kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello1_deployment.yaml
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello3_deployment.yaml

echo "waiting for hello1-deploy"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n hybrid-hello \
  wait --for=condition=ready pod -l app=hello1-deploy
echo "waiting for hello3-deploy"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n http-hello \
  wait --for=condition=ready pod -l app=hello3-deploy

kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello1_service.yaml
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello3_service.yaml