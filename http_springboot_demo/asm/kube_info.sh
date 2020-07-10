#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"

v3_pod=$(k get pod -l app=http-hello-deploy -n hello -o jsonpath='{.items[2].metadata.name}')
k -n hello get pod $v3_pod --export=true -o yaml > "$v3_pod.yaml"