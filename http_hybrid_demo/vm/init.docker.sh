#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ..
source hybrid.config

VMS=("$VM_PUB_1" "$VM_PUB_2" "$VM_PUB_3")
for vm in "${VMS[@]}"; do
  if [ "$vm" = "" ]; then
    echo "continue"
  else
    ssh root@"$vm" "apt-get update && apt-get install -y docker.io"
    echo "docker verion on $vm:"
    ssh root@"$vm" "docker version"
  fi
done
