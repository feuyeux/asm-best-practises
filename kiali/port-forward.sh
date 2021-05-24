#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

alias k="kubectl --kubeconfig $HOME/shop_config/kubeconfig/ack_production"
kiali_pod=$(k get pod -l app=kiali -n istio-system -o jsonpath='{.items[0].metadata.name}')
k -n istio-system port-forward $kiali_pod 20001:20001