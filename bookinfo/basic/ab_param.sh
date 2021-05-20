#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias m="kubectl --kubeconfig $MESH_CONFIG"
alias k="kubectl --kubeconfig $USER_CONFIG"

echo "deploy control plane"
# m delete -f param/
m apply -f param/
echo "done\n"

# echo "watching productpage log"
# productpage_pod=$(k get pod -l app=productpage -o jsonpath='{.items[0].metadata.name}')
# k exec $productpage_pod -c productpage -- curl reviews:9080/

#可以是任意数字
productId=100
GATEWAY=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Test black [http://${GATEWAY}/reviews/${productId}?star=black]:"
for i in {1..3}; do
  curl -s "http://${GATEWAY}/reviews/${productId}?star=black" | jq 
done
echo "\nTest red [http://${GATEWAY}/reviews/${productId}?star=red]:"
for i in {1..3}; do
  curl -s "http://${GATEWAY}/reviews/${productId}?star=red" | jq 
done
echo "\nTest default http://${GATEWAY}/reviews/${productId}:"
for i in {1..3}; do
  curl -s "http://${GATEWAY}/reviews/${productId}" | jq 
done