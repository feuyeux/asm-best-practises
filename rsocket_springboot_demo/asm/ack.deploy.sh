#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
kubectl \
  --kubeconfig "$USER_CONFIG" version

echo "1 initialize..."
kubectl \
  --kubeconfig "$USER_CONFIG" \
  delete namespace rsocket-hello >/dev/null 2>&1

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  delete namespace rsocket-hello >/dev/null 2>&1

kubectl \
  --kubeconfig "$USER_CONFIG" \
  create ns rsocket-hello

kubectl \
  --kubeconfig "$USER_CONFIG" \
  label ns rsocket-hello istio-injection=enabled

echo "2 setup deployment"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello_serviceaccount.yaml
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello1_deployment.yaml
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello2_deployment.yaml
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello3_deployment.yaml

kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n rsocket-hello \
  get sa

echo "waiting for hello1-deploy"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n rsocket-hello \
  wait --for=condition=ready pod -l app=hello1-deploy

echo "waiting for hello2-deploy-v1"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n rsocket-hello \
  wait --for=condition=ready pod -l app=hello2-deploy-v1

echo "waiting for hello2-deploy-v2"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n rsocket-hello \
  wait --for=condition=ready pod -l app=hello2-deploy-v2

echo "waiting for hello2-deploy-v3"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n rsocket-hello \
  wait --for=condition=ready pod -l app=hello2-deploy-v3

echo "waiting for hello3-deploy"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n http-hello \
  wait --for=condition=ready pod -l app=hello3-deploy

kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n http-hello \
  get po

echo "3 setup service"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello1_service.yaml
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello2_service.yaml
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello3_service.yaml
