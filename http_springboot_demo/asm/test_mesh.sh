#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
IP=$(kubectl --kubeconfig "$USER_CONFIG" \
  -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Ingress gateway ip:$IP"

echo "Start test in loop:"
for ((i = 1; i <= 100; i++)); do
  curl -s $IP:8001/hello/feuyeux >/dev/null
done
for ((i = 1; i <= 10; i++)); do
  curl -s $IP:8001/hello/feuyeux >>result
  echo "" >>result
done
sort result | uniq -c | sort -nrk1
rm -f result
echo
for ((i = 1; i <= 100; i++)); do
  curl -s $IP:8001/bye >/dev/null
done
for ((i = 1; i <= 10; i++)); do
  curl -s $IP:8001/bye >>result
  echo "" >>result
done
sort result | uniq -c | sort -nrk1
echo
rm -f result
echo "Done."
