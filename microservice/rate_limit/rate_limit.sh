#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
version=1.9.5
export ISTIO_HOME=${HOME}/shop/istio-${version}
alias k="kubectl --kubeconfig $HOME/shop_config/kubeconfig/ack_production"
alias m="kubectl --kubeconfig $HOME/shop_config/kubeconfig/asm_production"

k apply -f data_plane/rate_limit_configmap.yaml
k apply -f ${ISTIO_HOME}/samples/ratelimit/rate-limit-service.yaml
m apply -f control_planerate_limit_envoyfilter.yaml

GATEWAY_URL=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl "http://$GATEWAY_URL/productpage"

# 请求频率大于 10 req/min 时，触发本地限流
WAIT=0.05

GW=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

for ((i = 1; i <= 20; i++)); do
  curl "http://$GW/productpage"
  sleep $WAIT
done
