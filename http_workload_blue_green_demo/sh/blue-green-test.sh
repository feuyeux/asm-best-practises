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

hello1_pod=$(k get pod -l app=hello1-deploy -n vm-blue-green -o jsonpath={.items..metadata.name})

verify_in_loop() {
  for i in {1..8}; do
    echo "  >>> test hello2-svc.vm-blue-green.svc.cluster.local"
    k exec "$hello1_pod" -c hello-v1-deploy -n vm-blue-green -- \
    curl -s hello2-svc.vm-blue-green.svc.cluster.local:8001/hello/eric
    echo
  done
}

echo "1 Test blue-green 1:1"
m apply -f yaml/wl1.yaml
m apply -f yaml/wl3.yaml
m get workloadentry -n vm-blue-green -o wide
verify_in_loop

echo "2 Test blue-green 2:1"
m apply -f yaml/wl2.yaml
m get workloadentry -n vm-blue-green -o wide
verify_in_loop

echo "3 Test blue-green 1:2"
m delete -f yaml/wl2.yaml
m apply -f yaml/wl4.yaml
m get workloadentry -n vm-blue-green -o wide
verify_in_loop

echo "4 Test blue-green 2:2"
m apply -f yaml/wl2.yaml
m get workloadentry -n vm-blue-green -o wide
verify_in_loop
