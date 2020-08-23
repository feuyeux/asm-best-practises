#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
source blue-green.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n hello-grouping -o jsonpath={.items..metadata.name})

verify_in_loop() {
  for i in {1..8}; do
    echo ">$i test hello2-svc.hello-grouping.svc.cluster.local"
    resp=$(k exec "$hello1_pod" -c hello-v1-deploy -n hello-grouping -- \
      curl -s hello2-svc.hello-grouping.svc.cluster.local:8001/hello/eric)
    if [[ "no healthy upstream" == $resp ]]; then
      echo "stop, no healthy upstream."
      exit
    fi
    echo "$resp"
  done
}

m get workloadentry -n hello-grouping -o wide
verify_in_loop
