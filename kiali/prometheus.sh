#!/usr/bin/env sh
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit

alias k="kubectl --kubeconfig $HOME/shop_config/kubeconfig/ack_production"

k apply -f $HOME/shop/istio-1.9.5/samples/addons/prometheus.yaml
