#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config

kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello_serviceaccount.yaml

kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello1_deployment.yaml

echo "waiting for hello1-deploy"
kubectl \
  --kubeconfig "$USER_CONFIG" \
  -n hybrid-hello \
  wait --for=condition=ready pod -l app=hello1-deploy

kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello1_service.yaml

####
kubectl \
  --kubeconfig "$USER_CONFIG" \
  apply -f data_plane/hello2_service.yaml