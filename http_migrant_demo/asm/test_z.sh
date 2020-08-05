#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config
alias k="kubectl --kubeconfig $USER_CONFIG"
IP=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Ingress gateway ip:$IP"
echo "Start test in loop:"
echo >z_result
for i in {1..100}; do
  resp=$(curl -s "$IP":8004/hello/asm)
  echo $i "$resp"
  echo "$resp" >>z_result
done
sort z_result | uniq -c | sort -nrk1
rm -rf z_result
