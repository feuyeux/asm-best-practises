#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config
alias k="kubectl --kubeconfig $USER_CONFIG"

echo "1 initialize..."
k delete namespace http-reciprocal-hello >/dev/null 2>&1
k create ns http-reciprocal-hello
k label ns http-reciprocal-hello istio-injection=enabled

k apply -f data_plane/http-reciprocal-hello-all.yaml
echo "waiting for hello1-deploy"
k -n http-reciprocal-hello wait --for=condition=ready pod -l app=hello1-deploy

k apply -f data_plane/hello1_service.yaml