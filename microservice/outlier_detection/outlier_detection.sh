#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

# kubeconfig of user's kubenetes cluster
USER_CONFIG=$HOME/shop_config/kubeconfig/ack_production
# kubeconfig of user's servicemesh cluster
MESH_CONFIG=$HOME/shop_config/kubeconfig/asm_production
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

if [ "n" = "$1" ]; then
  k delete ns http-hello
  m delete ns http-hello
  k create ns http-hello
  m create ns http-hello
  k label ns http-hello istio-injection=enabled
  m label ns http-hello istio-injection=enabled
fi

k -n http-hello apply -f http_outlier_detection.yaml
m -n http-hello apply -f asm_http_outlier_detection.yaml

GW=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $GW
sleep 3s
# sh fault_injection.sh
# sleep 3s

echo "start to test[500]:"
for ((i = 1; i <= 10; i++)); do
  result=$(curl -s ${GW}:8001/hello/500)
  if [ "no healthy upstream" = "$result" ]; then
    echo "waiting for pod"
    sleep 10
  else
    echo $result
    # sleep 50ms
    sleep 0.05
  fi
done
if [ "no healthy upstream" = "$result" ]; then
  exit 1
fi
echo
echo "start to test[od]:"
for ((i = 1; i <= 20; i++)); do
  curl -s ${GW}:8001/hello/od
  # sleep 1s
  sleep 1
  echo
done
