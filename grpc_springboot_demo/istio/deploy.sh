#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

USER_CONFIG=~/shop_config/bj_config
MESH_CONFIG=~/shop_config/bj_164_config

kubectl \
  --kubeconfig "$USER_CONFIG" \
  delete namespace grpc >/dev/null 2>&1

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  delete namespace grpc >/dev/null 2>&1

kubectl \
  --kubeconfig "$USER_CONFIG" \
  create ns grpc

kubectl \
  --kubeconfig "$USER_CONFIG" \
  label ns grpc istio-injection=enabled

echo "setup deployment & service"

kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n grpc \
  apply -f kube/consumer.yaml
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n grpc \
  apply -f kube/provider1.yaml
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n grpc \
  apply -f kube/provider2.yaml

kubectl \
  --kubeconfig "$HOME"/shop_config/bj_config \
  -n grpc \
  get po

echo "setup gateway"

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  create ns grpc

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n grpc \
  apply -f networking/gateway.yaml

echo "setup virtual service"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n grpc \
  apply -f networking/gateway-virtual-service.yaml

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n grpc \
  apply -f networking/provider-virtual-service.yaml

kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n grpc \
  apply -f networking/consumer-virtual-service.yaml

echo "setup destination rule"
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n grpc \
  apply -f networking/provider-destination-rule.yaml
kubectl \
  --kubeconfig "$MESH_CONFIG" \
  -n grpc \
  apply -f networking/consumer-destination-rule.yaml
