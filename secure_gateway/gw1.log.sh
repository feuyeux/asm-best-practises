#!/usr/bin/env bash
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
#
USER_CONFIG=$HOME/shop_config/kubeconfig/ack_production
alias k="kubectl --kubeconfig $USER_CONFIG"
k logs -f -n istio-system $(k get pod -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].metadata.name}')