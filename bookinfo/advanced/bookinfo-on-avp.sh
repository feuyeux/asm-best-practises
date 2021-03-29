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
alias m="kubectl --kubeconfig $MESH_CONFIG"
k create ns bookinfo
m create ns bookinfo
m label ns bookinfo istio-injection=enabled
m apply -n bookinfo -f mesh/gateway.yaml

# vm

# se/we

#入口网关
GATEWAY_URL=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

#验证
echo "http://${GATEWAY_URL}/productpage"
curl -svI "http://${GATEWAY_URL}/productpage"
