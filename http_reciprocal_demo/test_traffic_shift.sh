#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source reciprocal.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"
m get IstioGateway -n istio-system -o jsonpath='{.items[0].spec.ports[?(@.name=="http-reciprocal")]}'
IP=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo
echo "Ingress gateway ip:$IP"
echo "Warm-up..."
for i in {1..20}; do
  curl -s "$IP":8004/hello/eric
  echo
done
echo "Test route n a loop"
echo >test_traffic_shift_result
for i in {1..100}; do
  resp=$(curl -s "$IP":8004/hello/eric)
  echo "$resp" >>test_traffic_shift_result
done

echo "expected 30%(Hello eric)-60%(Bonjour eric)-10%(Hola eric):"
sort test_traffic_shift_result | grep -v "^[[:space:]]*$" | uniq -c | sort -nrk1

rm -rf test_traffic_shift_result
