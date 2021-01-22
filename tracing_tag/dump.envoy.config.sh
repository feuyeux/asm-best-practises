#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source config

alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

timestamp=$(date "+%Y%m%d-%H%M%S")

hello2_v1_pod=$(k get pod -l app=hello2-deploy-v1 -n http-hello -o jsonpath={.items..metadata.name})
k -n http-hello exec $hello2_v1_pod -c istio-proxy \
-- curl -s "http://localhost:15000/config_dump?resource=dynamic_listeners" >dynamic_listeners-"$timestamp".json