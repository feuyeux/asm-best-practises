#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source circuit_breaking.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n grpc-circuit-breaking -o jsonpath={.items..metadata.name})

for i in {1..100}; do
  k exec "$hello1_pod" -c hello-v2-deploy -n grpc-circuit-breaking -- \
    grpcurl -v -plaintext -d '{"name":"'${i}' eric"}' \
    localhost:7001 org.feuyeux.grpc.Greeter/SayHello &
done