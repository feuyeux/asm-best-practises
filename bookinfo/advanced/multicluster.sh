#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
version=1.8.4
export ISTIO_HOME=${HOME}/shop/istio-${version}
source config
alias ck="kubectl --kubeconfig $ACK_CONFIG"
alias sk1="kubectl --kubeconfig $ASK1_CONFIG"
alias sk2="kubectl --kubeconfig $ASK2_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

m label ns default istio-injection=enabled
ck label ns default istio-injection=enabled
sk1 label ns default istio-injection=enabled
sk2 label ns default istio-injection=enabled

m apply -f mesh/gateway.yaml
sk1 apply -f kube/productpage.yaml
sk2 apply -f kube/details.yaml
sk2 apply -f kube/ratings.yaml
sk2 apply -f kube/reviews.yaml
sk2 apply -f kube/reviews1.yaml
sk2 apply -f kube/reviews2.yaml
sk2 apply -f kube/reviews3.yaml