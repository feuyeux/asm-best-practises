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
hello2_pod=$(k get pod -l app=hello2-deploy -n grpc-circuit-breaking -o jsonpath={.items..metadata.name})

echo "1 Test grpcurl $hello2_pod localhost"
k exec "$hello2_pod" -c hello-v3-deploy -n grpc-circuit-breaking -- \
  grpcurl -plaintext -d '{"name":"eric"}' localhost:7001 \
  org.feuyeux.grpc.Greeter/SayHello | jq '.reply'
echo "2 Test grpcurl $hello1_pod localhost"
k exec "$hello1_pod" -c hello-v2-deploy -n grpc-circuit-breaking -- \
  grpcurl -plaintext -d '{"name":"eric"}' localhost:7001 \
  org.feuyeux.grpc.Greeter/SayHello | jq '.reply'
echo "3 Test grpcurl $hello1_pod -> hello2-svc.grpc-circuit-breaking.svc.cluster.local"
k exec "$hello1_pod" -c hello-v2-deploy -n grpc-circuit-breaking -- \
  grpcurl -plaintext -d '{"name":"eric"}' \
  -import-path /opt -proto hello.proto \
  hello2-svc.grpc-circuit-breaking.svc.cluster.local:7001 \
  org.feuyeux.grpc.Greeter/SayHello | jq '.reply'
echo "4 Test ghz $hello1_pod -> hello2-svc.grpc-circuit-breaking.svc.cluster.local"
k exec "$hello1_pod" -c hello-v2-deploy -n grpc-circuit-breaking -- \
  ghz --insecure -d '{"name":"eric"}' \
  --proto /opt/hello.proto \
  --call org.feuyeux.grpc.Greeter/SayHello \
  -n 1 \
  -c 1 \
  hello2-svc.grpc-circuit-breaking.svc.cluster.local:7001
