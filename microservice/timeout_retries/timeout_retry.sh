#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

alias k="kubectl --kubeconfig $HOME/shop_config/kubeconfig/ack_production"
alias m="kubectl --kubeconfig $HOME/shop_config/kubeconfig/asm_production"

if [ "n" = "$1" ]; then
  k delete ns http-hello
  m delete ns http-hello
  k create ns http-hello
  m create ns http-hello
  k label ns http-hello istio-injection=enabled
  m label ns http-hello istio-injection=enabled
fi

echo "deploy data plane"
k -n http-hello apply -f ack_http_timeout.yaml
echo
echo "deploy control plane"
m -n http-hello apply -f mesh/gateway.yaml
m -n http-hello apply -f mesh/vs-a-timeout.yaml
m -n http-hello apply -f mesh/vs-b.yaml
m -n http-hello apply -f mesh/dr-a.yaml
m -n http-hello apply -f mesh/dr-b.yaml

k -n http-hello wait --for=condition=ready pod -l app=hello-a-deploy,version=v1

a1=$(k -n http-hello get po -l app=hello-a-deploy,version=v1 -o jsonpath={.items..metadata.name})
for ((i = 1; i <= 3; i++)); do
  k -n http-hello exec $a1 hello-a-deploy -c hello-a-deploy -- curl -s hello-b-svc:8001/hello/internal
  sleep 0.05
  echo
done
echo
GW=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "test timeout:"
for ((i = 1; i <= 20; i++)); do
  result=$(curl -s -H "Host: feuyeux.org" ${GW}:8001/hello/timeout)
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
m -n http-hello apply -f mesh/vs-a-retry.yaml
echo "test retry:"
for ((i = 1; i <= 20; i++)); do
  result=$(curl -s -H "Host: feuyeux.org" ${GW}:8001/hello/retry)
  if [ "no healthy upstream" = "$result" ]; then
    echo "waiting for pod"
    sleep 10
  else
    echo $result
    # sleep 50ms
    sleep 0.05
  fi
done
