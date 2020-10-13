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

k exec "$hello1_pod" -c hello-v2-deploy -n grpc-circuit-breaking -- \
  ghz --insecure -d '{"name":"eric"}' \
  --proto /opt/hello.proto \
  --call org.feuyeux.grpc.Greeter/SayHello \
  -n 2000 \
  -c 20 \
  -q 500 \
  localhost:7001

k exec "$hello1_pod" -c hello-v2-deploy -n grpc-circuit-breaking -- \
  ghz --insecure -d '{"name":"eric"}' \
  --proto /opt/hello.proto \
  --call org.feuyeux.grpc.Greeter/SayHello \
  -n 2000 \
  -c 20 \
  -q 500 \
  hello2-svc.grpc-circuit-breaking.svc.cluster.local:7001
