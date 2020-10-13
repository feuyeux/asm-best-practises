#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
source tracing.config

VMS=("$VM_PUB_1" "$VM_PUB_2" "$VM_PUB_3")
for vm in "${VMS[@]}"; do
  echo "init $vm ssh authorized_keys"
  ssh root@"$vm" "mkdir -p .ssh"
  ssh root@"$vm" "cat >> .ssh/authorized_keys" <"$HOME"/.ssh/id_rsa.pub
done
