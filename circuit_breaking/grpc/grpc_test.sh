#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source circuit_breaking.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

m delete namespace grpc-circuit-breaking >/dev/null 2>&1
m create ns grpc-circuit-breaking
m label ns grpc-circuit-breaking istio-injection=enabled
m apply -f yaml/asm-all.yaml

hello1_pod=$(k get pod -l app=hello1-deploy -n grpc-circuit-breaking -o jsonpath={.items..metadata.name})
k exec "$hello1_pod" -c hello-v2-deploy -n grpc-circuit-breaking -- \
  grpcurl -plaintext -d '{"name":"eric"}' localhost:7001 \
  org.feuyeux.grpc.Greeter/SayHello | jq '.reply'

k exec "$hello1_pod" -c hello-v2-deploy -n grpc-circuit-breaking -- \
  grpcurl -v -plaintext -d '{"name":"eric"}' localhost:7001 org.feuyeux.grpc.Greeter/SayHello

k exec "$hello1_pod" -c hello-v2-deploy -n grpc-circuit-breaking -- \
  ghz --insecure --call org.feuyeux.grpc.Greeter/SayHello -d '{"name":"eric"}' \
  -n 20 \
  -c 20 \
  localhost:7001

k exec "$hello1_pod" -c hello-v2-deploy -n grpc-circuit-breaking -- \
  ghz --insecure -c20 -n100 --call org.feuyeux.grpc.Greeter/SayHello -d '{"name":"eric"}' localhost:7001 -O csv