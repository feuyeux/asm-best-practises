#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
version=1.8.4
export ISTIO_HOME=${HOME}/shop/istio-${version}
source config
alias k="kubectl --kubeconfig $ACK_CONFIG"
ingressgateway_pod=$(k get pod -l app=istio-ingressgateway -n istio-system -o jsonpath='{.items[1].metadata.name}')
k -n istio-system logs -f $ingressgateway_pod