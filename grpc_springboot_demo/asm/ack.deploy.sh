#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config

echo "1 initialize..."

echo " delete ns grpc-hello for cluster"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  delete namespace grpc-hello >/dev/null 2>&1

echo " delete ns grpc-hello for mesh"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  delete namespace grpc-hello >/dev/null 2>&1
sleep 10s
echo " create ns grpc-hello"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  create ns grpc-hello
sleep 5s
kubectl \
  --kubeconfig "$USER_CONFIG" \
  label ns grpc-hello istio-injection=enabled

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
  -n grpc-hello \
  get sa

echo "waiting for hello1-deploy"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n grpc-hello \
  wait --for=condition=ready pod -l app=hello1-deploy

echo "waiting for hello2-deploy-v1"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n grpc-hello \
  wait --for=condition=ready pod -l app=hello2-deploy-v1

echo "waiting for hello2-deploy-v2"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n grpc-hello \
  wait --for=condition=ready pod -l app=hello2-deploy-v2

echo "waiting for hello2-deploy-v3"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n grpc-hello \
  wait --for=condition=ready pod -l app=hello2-deploy-v3

echo "waiting for hello3-deploy"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n grpc-hello \
  wait --for=condition=ready pod -l app=hello3-deploy

kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n grpc-hello \
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