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
  echo >test_traffic_result
  for i in {1..100}; do
    resp=$(k exec "$hello1_pod" -c hello-v1-deploy -n hello-grouping -- curl -s hello2-svc.hello-grouping.svc.cluster.local:8001/hello/eric)
    if [[ "no healthy upstream" == $resp ]]; then
      echo "stop, no healthy upstream."
      rm -f test_traffic_result
      exit
    fi
    echo "$resp" >>test_traffic_result
  done
  echo "result:"
  sort test_traffic_result | grep -v "^[[:space:]]*$" | uniq -c | sort -nrk1
  rm -f test_traffic_result
}

echo "1 Test blue-green 2:1"
m delete workloadentry mesh-expansion-hello2-svc-4 -n hello-grouping
m get workloadentry -n hello-grouping -o wide
verify_in_loop

echo "2 Test blue-green 1:1"
m delete workloadentry mesh-expansion-hello2-svc-2 -n hello-grouping
m get workloadentry -n hello-grouping -o wide
verify_in_loop

echo "3 Test blue-green 1:2"
m apply -f yaml/wl4.yaml
m get workloadentry -n hello-grouping -o wide
verify_in_loop

echo "4 Test blue-green 2:2"
m apply -f yaml/wl2.yaml
m get workloadentry -n hello-grouping -o wide
verify_in_loop
