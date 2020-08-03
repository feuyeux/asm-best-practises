#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source vm.config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias s="kubectl --kubeconfig $MESH_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n http-hello -o jsonpath={.items..metadata.name})
echo "test access hello1"
k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s hello1-svc.hello.svc.cluster.local:8001/hello/eric
echo
echo "test access vm ip directly"
k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s "$VM_1_PRI_IP":8001/hello/eric
echo
k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s "$VM_2_PRI_IP":8001/hello/eric
echo
echo "test access hello2"
k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -sv hello2-svc.hello.svc.cluster.local:8001/hello/eric
echo
echo "test hello2 service"
k get service hello2-svc -n http-hello -o jsonpath={.spec.clusterIP}
echo
#current_time=$(date "+%Y-%m-%d %H:%M:%S")
now=$(date "+%m_%d_%H_%M_%S")
k get service hello2-svc -n http-hello -o yaml >/tmp/hello2.service".$now".yaml
s get serviceentry -n http-hello -o yaml >/tmp/hello2.serviceentry".$now".yaml
s get workloadentry -n http-hello -o yaml >/tmp/hello2.workloadentries".$now".yaml
echo "/tmp/hello2.service.$now.yaml"
echo "/tmp/hello2.serviceentry.$now.yaml"
echo "/tmp/hello2.workloadentries.$now.yaml"
#k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- ping hello2-svc.hello.svc.cluster.local
