#!/usr/bin/env bash
# sleep --(token)--> httpbin
# local --(token)--> ingressgateway --> httpbin

SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

USER_CONFIG=~/shop_config/ack_bj
MESH_CONFIG=~/shop_config/asm_bj
ISTIO_HOME=~/shop/istio-1.7.5

kubectl --kubeconfig "$USER_CONFIG" version --short
kubectl --kubeconfig "$MESH_CONFIG" version --short

echo "0. Initialize"
kubectl --kubeconfig "$USER_CONFIG" create ns foo >/dev/null 2>&1
kubectl --kubeconfig "$USER_CONFIG" label ns foo istio-injection=enabled >/dev/null 2>&1

echo "1. Deploy two workloads: httpbin and sleep"
kubectl --kubeconfig "$USER_CONFIG" -n foo apply -f "$ISTIO_HOME"/samples/httpbin/httpbin.yaml
kubectl --kubeconfig "$USER_CONFIG" -n foo apply -f "$ISTIO_HOME"/samples/sleep/sleep.yaml
kubectl --kubeconfig "$USER_CONFIG" -n foo wait --for=condition=ready pod -l app=httpbin
kubectl --kubeconfig "$USER_CONFIG" -n foo wait --for=condition=ready pod -l app=sleep
kubectl --kubeconfig "$USER_CONFIG" -n foo get svc,pod

echo "2. Verify that sleep successfully communicates with httpbin"
sleep_pod=$(kubectl --kubeconfig "$USER_CONFIG" get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name})
kubectl --kubeconfig "$USER_CONFIG" exec "$sleep_pod" -c sleep -n foo -- curl http://httpbin.foo:8000/ip -s
RESULT=$(kubectl --kubeconfig "$USER_CONFIG" \
  exec "$sleep_pod" -c sleep -n foo -- curl http://httpbin.foo:8000/ip -s -o /dev/null -w "%{http_code}")
if [[ $RESULT != "200" ]]; then
  echo "http_code($RESULT) should be 200"
  exit
fi

kubectl --kubeconfig "$MESH_CONFIG" create ns foo >/dev/null 2>&1
kubectl --kubeconfig "$MESH_CONFIG" -n foo apply -f "$ISTIO_HOME"/samples/httpbin/httpbin-gateway.yaml
GATEWAY_URL=$(kubectl --kubeconfig "$USER_CONFIG" -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
RESULT=$(curl -s "http://${GATEWAY_URL}/ip" -s -o /dev/null -w "%{http_code}")
if [[ $RESULT != "200" ]]; then
  echo "Failed. http_code($RESULT) should be 200"
  exit
fi
echo "Passed"

echo "3. Creates the jwt-example request authentication policy"
kubectl --kubeconfig "$MESH_CONFIG" apply -f jwt-example.yaml
kubectl --kubeconfig "$MESH_CONFIG" -n istio-system get requestauthentication

echo "4. Verify that a request with an invalid JWT is denied(401)"
# -H "Authorization: Bearer $TOKEN"
RESULT=$(curl "http://${GATEWAY_URL}/headers" -s -o /dev/null -H "Authorization: Bearer invalidToken" -w "%{http_code}")

if [[ $RESULT != "401" ]]; then
  echo "Failed. http_code($RESULT) should be 401"
  exit
fi
echo "Passed"
