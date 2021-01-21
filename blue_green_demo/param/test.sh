#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source config
alias k="kubectl --kubeconfig $USER_CONFIG"
ingressGatewayIp=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "http://$ingressGatewayIp:8001/hello/eric?version=v1"
curl "http://$ingressGatewayIp:8001/hello/eric?version=v1"
echo "\nhttp://$ingressGatewayIp:8001/hello/eric?version=v2"
curl "http://$ingressGatewayIp:8001/hello/eric?version=v2"
echo "\nhttp://$ingressGatewayIp:8001/hello/eric?version=v3"
curl "http://$ingressGatewayIp:8001/hello/eric?version=v3"