#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"
IP=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
cd ..
java -Dserver.port=6666 -Dback.host="$IP" -jar test_jar/ws-requester.jar
