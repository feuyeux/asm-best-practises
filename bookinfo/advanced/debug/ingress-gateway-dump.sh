#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
EXECUTE_PATH=$(PWD)
cd "$SCRIPT_PATH" || exit

source ../config
alias k="kubectl --kubeconfig $ACK_CONFIG"
ingressgateway_pod=$(k get pod -l app=istio-ingressgateway -n istio-system -o jsonpath='{.items[0].metadata.name}')
echo "config_dump from $ingressgateway_pod"
k -n istio-system exec $ingressgateway_pod \
        -c istio-proxy \
        -- curl -s "http://localhost:15000/config_dump" >${EXECUTE_PATH}/ingressgateway_config_dump.json