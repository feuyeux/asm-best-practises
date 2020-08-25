#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../tracing.config
alias k="kubectl --kubeconfig $USER_CONFIG"
zipkin_ip=$(k get svc -n istio-system|grep zipkin|awk -F ' ' '{print $4}')
echo "http://$zipkin_ip:9411/"