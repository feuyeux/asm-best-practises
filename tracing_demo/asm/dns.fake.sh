#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../tracing.config
alias k="kubectl --kubeconfig $USER_CONFIG"
hello3_svc_ip=$(k get svc hello3-svc -n trace-hello -o jsonpath='{.spec.clusterIP}')
echo "$hello3_svc_ip hello3-svc.trace-hello.svc.cluster.local" >dns_record

VMS=("$VM_PUB_1" "$VM_PUB_2" "$VM_PUB_3")
for vm in "${VMS[@]}"; do
  ssh root@"$vm" "sed -i '/hello3-svc.trace-hello.svc.cluster.local/d' /etc/hosts"
  ssh root@"$vm" "cat >> /etc/hosts" <dns_record
done
rm -rf dns_record

for vm in "${VMS[@]}"; do
  echo "::::$vm::::"
  ssh root@"$vm" "cat /etc/hosts"
done
echo
for vm in "${VMS[@]}"; do
  hello3_pod_ip=$(k get pod -l app=hello3-deploy -n http-reciprocal-hello -o jsonpath={.items[*].status.podIP})
  echo "Test access to hello3 pod on $vm"
  ssh root@"$vm" "curl -s $hello3_pod_ip:8001/hello/pod_testing_msg"
  echo
  echo "Test access to hello3 service on $vm"
  ssh root@"$vm" "curl -s hello3-svc.trace-hello.svc.cluster.local:8001/hello/svc_testing_msg"
  echo
done
