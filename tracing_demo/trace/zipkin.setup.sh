#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../tracing.config
alias k="kubectl --kubeconfig $USER_CONFIG"
k apply -f zipkin-deployment.yaml
k -n istio-system wait --for=condition=ready pod -l app=zipkin-server
k apply -f zipkin-service.yaml
k get svc zipkin -n istio-system
