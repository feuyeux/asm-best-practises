#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source circuit_breaking.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

FORTIO_POD=$(k -n http-circuit-breaking get pods -lapp=fortio -o 'jsonpath={.items[0].metadata.name}')

echo "== 1 Test access =="
k exec -it "$FORTIO_POD" -c fortio -n http-circuit-breaking -- \
  /usr/bin/fortio load -curl http://hello2-svc:8001/hello/eric
echo
echo "== 2 Test access with 2 concurrent connections (-c 2) and send 20 requests (-n 20) =="
result_c2_n20=$(k exec -it "$FORTIO_POD" -c fortio -n http-circuit-breaking -- \
  /usr/bin/fortio load -c 2 -qps 0 -n 20 -loglevel Warning http://hello2-svc:8001/hello/eric)
echo "$result_c2_n20"
echo
echo "circuit breaking status:"
echo "$result_c2_n20" | grep Code
echo
echo "== 3 Test access with 3 concurrent connections (-c 3) and send 30 requests (-n 30) =="
result_c3_n30=$(k exec -it "$FORTIO_POD" -c fortio -n http-circuit-breaking -- \
  /usr/bin/fortio load -c 3 -qps 0 -n 30 -loglevel Warning http://hello2-svc:8001/hello/eric)
echo "$result_c3_n30"
echo
echo "circuit breaking status:"
echo "$result_c3_n30" | grep Code
echo
echo "== 4 Check envoy pending =="
k exec -it "$FORTIO_POD" -c istio-proxy -n http-circuit-breaking -- \
  pilot-agent request GET stats | grep hello2-svc.http-circuit-breaking | grep pending
