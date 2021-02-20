#!/usr/bin/env bash
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source config

echo "init $VM ssh authorized_keys"
ssh root@"$VM" "mkdir -p .ssh"
ssh root@"$VM" "cat >> .ssh/authorized_keys" <"$HOME"/.ssh/id_rsa.pub
