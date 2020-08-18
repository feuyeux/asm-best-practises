#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"
IP=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://"$IP":9001

echo "Start test in loop:"
for ((i = 1; i <= 20; i++)); do
  rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://"$IP":9001
done
#for ((i = 1; i <= 100; i++)); do
#  rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://"$IP":9001 >>result
#done
#echo " expected Hello-Bonjour-Hola 30-60-10:"
#sort result | uniq -c | sort -nrk1
#rm -f result
#echo "Done."