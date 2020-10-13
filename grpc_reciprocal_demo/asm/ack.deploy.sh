#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../reciprocal.config
alias k="kubectl --kubeconfig $USER_CONFIG"

echo "1 initialize..."
k delete namespace grpc-reciprocal-hello >/dev/null 2>&1
k create ns grpc-reciprocal-hello
k label ns grpc-reciprocal-hello istio-injection=enabled

k apply -f data_plane/grpc-reciprocal-hello-all.yaml
echo "waiting for hello1-deploy"
k -n grpc-reciprocal-hello wait --for=condition=ready pod -l app=hello1-deploy
echo "waiting for hello3-deploy"
k -n grpc-reciprocal-hello wait --for=condition=ready pod -l app=hello3-deploy

k -n grpc-reciprocal-hello get pod,svc
