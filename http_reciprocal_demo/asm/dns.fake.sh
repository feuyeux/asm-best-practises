#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../reciprocal.config
alias k="kubectl --kubeconfig $USER_CONFIG"
hello3_svc_ip=$(k get svc hello3-svc -n hybrid-hello -o jsonpath='{.spec.clusterIP}')
echo "$hello3_svc_ip hello3-svc.http-reciprocal-hello.svc.cluster.local" > dns_record

VMS=("$VM_PUB_1" "$VM_PUB_2" "$VM_PUB_3")
for vm in "${VMS[@]}"; do
  ssh root@"$vm" "cat >> /etc/hosts" < dns_record
done
rm -rf dns_record

for vm in "${VMS[@]}"; do
  echo "::::$vm::::"
  ssh root@"$vm" "cat /etc/hosts"
done
