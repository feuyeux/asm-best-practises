#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
version=1.9.5
export ISTIO_HOME=${HOME}/shop/istio-${version}
# kubeconfig of user's kubenetes cluster
USER_CONFIG=$HOME/shop_config/kubeconfig/ack_production
# kubeconfig of user's servicemesh cluster
MESH_CONFIG=$HOME/shop_config/kubeconfig/asm_production
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

k apply -f data_plane/rate_limit_configmap.yaml
k apply -f ${ISTIO_HOME}/samples/ratelimit/rate-limit-service.yaml
m apply -f control_plane/rate_limit_envoyfilter.yaml