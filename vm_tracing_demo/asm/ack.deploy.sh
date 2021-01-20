#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../tracing.config
alias k="kubectl --kubeconfig $USER_CONFIG"

echo "1 initialize..."
k delete namespace trace-hello >/dev/null 2>&1
k create ns trace-hello
k label ns trace-hello istio-injection=enabled

k apply -f data_plane/trace-hello-all.yaml
echo "waiting for hello1-deploy"
k -n trace-hello wait --for=condition=ready pod -l app=hello1-deploy
echo "waiting for hello3-deploy"
k -n trace-hello wait --for=condition=ready pod -l app=hello3-deploy

k -n trace-hello get pod,svc -o wide
