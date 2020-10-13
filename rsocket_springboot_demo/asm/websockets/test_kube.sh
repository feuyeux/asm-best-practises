#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n rsocket-ws-hello -o jsonpath={.items..metadata.name})
hello2_pod1=$(k get pod -l app=hello2-deploy -n rsocket-ws-hello -o jsonpath='{.items[0].metadata.name}')
hello2_pod2=$(k get pod -l app=hello2-deploy -n rsocket-ws-hello -o jsonpath='{.items[1].metadata.name}')
hello2_pod3=$(k get pod -l app=hello2-deploy -n rsocket-ws-hello -o jsonpath='{.items[2].metadata.name}')
hello3_pod=$(k get pod -l app=hello3-deploy -n rsocket-ws-hello -o jsonpath={.items..metadata.name})

echo "Check traffic to localhost:"
k exec "$hello1_pod" -c hello-v1-deploy -n rsocket-ws-hello -- /var/bin/rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://localhost:9001
k exec "$hello2_pod1" -c hello-v1-deploy -n rsocket-ws-hello -- /var/bin/rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://localhost:9001
k exec "$hello2_pod2" -c hello-v2-deploy -n rsocket-ws-hello -- /var/bin/rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://localhost:9001
k exec "$hello2_pod3" -c hello-v3-deploy -n rsocket-ws-hello -- /var/bin/rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://localhost:9001
k exec "$hello3_pod" -c hello-v1-deploy -n rsocket-ws-hello -- /var/bin/rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://localhost:9001

echo "Check traffic to svc:"
k exec "$hello1_pod" -c hello-v1-deploy -n rsocket-ws-hello -- /var/bin/rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://hello1-svc.rsocket-ws-hello.svc.cluster.local:9001
k exec "$hello1_pod" -c hello-v1-deploy -n rsocket-ws-hello -- /var/bin/rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://hello2-svc.rsocket-ws-hello.svc.cluster.local:9001
k exec "$hello1_pod" -c hello-v1-deploy -n rsocket-ws-hello -- /var/bin/rsocket-cli --request --route=hello -i '{"value":"eric"}' ws://hello3-svc.rsocket-ws-hello.svc.cluster.local:9001
