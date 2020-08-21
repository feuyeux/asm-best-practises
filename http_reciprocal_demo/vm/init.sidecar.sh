#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
source reciprocal.config

VMS=("$VM_PUB_1" "$VM_PUB_2" "$VM_PUB_3")
for vm in "${VMS[@]}"; do
  echo "scp /tmp/istio-sidecar.deb root@$vm:/tmp/"
  scp ~/shop/istio-sidecar.1.6.4.deb root@"$vm":/tmp/
done