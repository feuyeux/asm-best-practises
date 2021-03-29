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
ingressgateway_pod=$(k get pod -l app=istio-ingressgateway -n istio-system -o jsonpath='{.items[0].metadata.name}')
k -n istio-system exec $ingressgateway_pod -c istio-proxy -- curl -s localhost/productpage
k -n istio-system exec $ingressgateway_pod -c istio-proxy -- curl -s 10.0.0.13:9080/productpage
k -n istio-system exec $ingressgateway_pod -c istio-proxy -- curl -s productpage.bookinfo:9080/productpage

