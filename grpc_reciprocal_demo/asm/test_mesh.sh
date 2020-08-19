#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../reciprocal.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n grpc-reciprocal-hello -o jsonpath={.items..metadata.name})

#k exec "$hello1_pod" -c hello-v1-deploy -n grpc-reciprocal-hello -- ping hello2-svc.grpc-reciprocal-hello.svc.cluster.local

echo "Test access hello1 localhost"
k exec "$hello1_pod" -c hello-v1-deploy -n grpc-reciprocal-hello \
 -- grpcurl -plaintext -d '{"name":"eric"}' localhost:7001 org.feuyeux.grpc.Greeter/SayHello
echo
hello3_pod=$(k get pod -l app=hello3-deploy -n grpc-reciprocal-hello -o jsonpath={.items..metadata.name})

echo "Test access hello3 localhost"
k exec "$hello3_pod" -c hello-v1-deploy -n grpc-reciprocal-hello \
 -- grpcurl -plaintext -d '{"name":"eric"}' localhost:7001 org.feuyeux.grpc.Greeter/SayHello
echo

echo "Test access hello1-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n grpc-reciprocal-hello -- grpcurl -plaintext -d '{"name":"eric"}' \
  hello1-svc.grpc-reciprocal-hello.svc.cluster.local:7004 org.feuyeux.grpc.Greeter/SayHello
echo

echo "Test access hello3-svc"
k exec "$hello1_pod" -c hello-v1-deploy -n grpc-reciprocal-hello -- grpcurl -plaintext -d '{"name":"eric"}' \
  hello3-svc.grpc-reciprocal-hello.svc.cluster.local:7001 org.feuyeux.grpc.Greeter/SayHello
echo