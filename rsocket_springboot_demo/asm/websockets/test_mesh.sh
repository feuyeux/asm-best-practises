#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"
IP=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
cd ../..
docker/rsocket-cli/bin/rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://"$IP":9001

#curl -s "localhost:6666/hello/eric"
