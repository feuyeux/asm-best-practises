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

# k apply -n bookinfo -f kube/sleep.yaml

# k get svc -n bookinfo -o wide
# k get svc -n bookinfo productpage -oyaml

SLEEP_POD=$(k -n bookinfo get pod -l app=sleep -o jsonpath='{.items[0].metadata.name}')
echo "SLEEP_POD=$SLEEP_POD"
echo
echo "Check productpage:"
k -n bookinfo exec $SLEEP_POD -c sleep -- curl -sIv productpage.bookinfo:9080/productpage
echo
echo "Check reviews:"
k -n bookinfo exec $SLEEP_POD -c sleep -- curl -s reviews.bookinfo:9080/reviews/1
echo
echo "Check details:"
k -n bookinfo exec $SLEEP_POD -c sleep -- curl -s details.bookinfo:9080/details/1
echo
echo "Check ratings:"
k -n bookinfo exec $SLEEP_POD -c sleep -- curl -s ratings.bookinfo:9080/ratings/1