#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n rsocket-ws-hello -o jsonpath={.items..metadata.name})

echo "Check traffic from hello1 pod($hello1_pod) localhost:"
#k exec "$hello1_pod" -c hello-v1-deploy -n rsocket-ws-hello -- netstat -plant
#k exec -it "$hello1_pod" -c hello-v1-deploy -n rsocket-ws-hello -- sh
k exec "$hello1_pod" -c hello-v1-deploy -n rsocket-ws-hello -- java -version