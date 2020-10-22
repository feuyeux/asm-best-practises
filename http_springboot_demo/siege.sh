#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm/asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"
IP=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Ingress gateway ip:$IP"
curl -s "$IP":8001/hello/asm
siege -c 5 "$IP":8001/hello/asm