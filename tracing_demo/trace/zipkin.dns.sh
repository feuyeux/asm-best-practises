#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../tracing.config
alias k="kubectl --kubeconfig $USER_CONFIG"
#zipkin_clusterIp=$(k get svc -n istio-system|grep zipkin|awk -F ' ' '{print $3}')
zipkin_clusterIp=$(k get svc -n istio-system|grep zipkin|awk -F ' ' '{print $4}')
echo "$zipkin_clusterIp zipkin.istio-system" > dns_record

VMS=("$VM_PUB_1" "$VM_PUB_2" "$VM_PUB_3")
for vm in "${VMS[@]}"; do
  ssh root@"$vm" "sed -i '/zipkin.istio-system/d' /etc/hosts"
  ssh root@"$vm" "cat >> /etc/hosts" < dns_record
done
rm -rf dns_record

for vm in "${VMS[@]}"; do
  echo "::::$vm::::"
  ssh root@"$vm" "cat /etc/hosts"
done
