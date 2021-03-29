#!/bin/bash
cd "$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/" || exit
echo "deploy..."
alias k="kubectl --kubeconfig ~/shop_config/kubeconfig/ack_production"
k delete ns hello >/dev/null 2>&1
k create ns hello >/dev/null 2>&1
k label ns hello istio-injection=enabled >/dev/null 2>&1
k -n hello apply -f Deployment.yaml
k -n hello apply -f Service.yaml

alias m="kubectl --kubeconfig ~/shop_config/kubeconfig/asm_production"
m delete ns hello >/dev/null 2>&1
m create ns hello >/dev/null 2>&1
m -n hello apply -f VirtualService.yaml

GATEWAY_URL=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "${GATEWAY_URL}"
curl -s "http://${GATEWAY_URL}:12321/hello/123"
curl -s "http://${GATEWAY_URL}:12321/bye/123"
curl -s "http://${GATEWAY_URL}:12321/123"
curl -s "http://${GATEWAY_URL}:12321/hello2/123"
curl -s "http://${GATEWAY_URL}:12321/hello3/123"