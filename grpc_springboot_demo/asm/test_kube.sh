#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n grpc-hello -o jsonpath={.items..metadata.name})
##
# hello2_pod=$(k get pod -l app=hello2-deploy -n grpc-hello -o jsonpath={.items..metadata.name})
# echo "hello2_pod=$hello2_pod"
##
hello2_pod1=$(k get pod -l app=hello2-deploy -n grpc-hello -o jsonpath='{.items[0].metadata.name}')
hello2_pod2=$(k get pod -l app=hello2-deploy -n grpc-hello -o jsonpath='{.items[1].metadata.name}')
hello2_pod3=$(k get pod -l app=hello2-deploy -n grpc-hello -o jsonpath='{.items[2].metadata.name}')
hello3_pod=$(k get pod -l app=hello3-deploy -n grpc-hello -o jsonpath={.items..metadata.name})

echo "[1/7] Check traffic from hello1 pod($hello1_pod) localhost:"
k exec "$hello1_pod" -c hello-v1-deploy -n grpc-hello -- grpcurl -plaintext -d '{"name":"eric"}' \
  localhost:7001 org.feuyeux.grpc.Greeter/SayHello
echo
echo "[2/7] Check traffic from hello2-v1 pod($hello2_pod1) localhost:"
k exec "$hello2_pod1" -c hello-v1-deploy -n grpc-hello -- grpcurl -plaintext \
  localhost:7001 org.feuyeux.grpc.Greeter/SayBye
echo
echo "[3/7] Check traffic from hello2-v2 pod($hello2_pod2) localhost:"
k exec "$hello2_pod2" -c hello-v2-deploy -n grpc-hello -- grpcurl -plaintext \
  localhost:7001 org.feuyeux.grpc.Greeter/SayBye
echo
echo "[4/7] Check traffic from hello2-v3 pod($hello2_pod3) localhost:"
k exec "$hello2_pod3" -c hello-v3-deploy -n grpc-hello -- grpcurl -plaintext \
  localhost:7001 org.feuyeux.grpc.Greeter/SayBye
echo
echo "[5/7] Check traffic from hello1 pod($hello3_pod) localhost:"
k exec "$hello3_pod" -c hello-v1-deploy -n grpc-hello -- grpcurl -plaintext -d '{"name":"eric"}' \
  localhost:7001 org.feuyeux.grpc.Greeter/SayHello
echo

echo "[6/7] Check traffic from hello1 pod($hello1_pod):"
k exec "$hello1_pod" -c hello-v1-deploy -n grpc-hello -- grpcurl -plaintext -d '{"name":"eric"}' \
  hello1-svc.grpc-hello.svc.cluster.local:7001 org.feuyeux.grpc.Greeter/SayHello
echo
echo "[7/7] Check traffic from hello2-v1 pod($hello2_pod1):"
k exec "$hello2_pod1" -c hello-v1-deploy -n grpc-hello -- grpcurl -plaintext \
  hello3-svc.grpc-hello.svc.cluster.local:7001 org.feuyeux.grpc.Greeter/SayBye
echo
