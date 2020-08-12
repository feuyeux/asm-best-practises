#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
IP=$(kubectl --kubeconfig "$USER_CONFIG" \
  -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "curl localhost:7777/hello/eric?host=$IP&port=7001:"
curl -s "localhost:7777/hello/eric?host=$IP&port=7001"
echo
####
echo "Start test in loop:"
for ((i = 1; i <= 20; i++)); do
  curl -s "localhost:7777/hello/eric?host=$IP&port=7001" >/dev/null
done
for ((i = 1; i <= 100; i++)); do
  curl -s "localhost:7777/hello/eric?host=$IP&port=7001" >>result
  echo "" >>result
done
echo " expected Hello-Bonjour-Hola 30-60-10:"
sort result | uniq -c | sort -nrk1
rm -f result
echo
for ((i = 1; i <= 20; i++)); do
  curl -s "localhost:7777/bye?host=$IP&port=7001" >/dev/null
done
for ((i = 1; i <= 100; i++)); do
  curl -s "localhost:7777/bye?host=$IP&port=7001" >>result
  echo "" >>result
done
echo " expected Bye bye-Au revoir-Adióbais 90-5-5:"
sort result | uniq -c | sort -nrk1
echo
rm -f result
echo "Done."
