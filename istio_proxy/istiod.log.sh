#!/usr/bin/env sh
set -e
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source config
alias k="kubectl --kubeconfig $USER_CONFIG"
istiod_pod=$(k get pod -l app=istiod -n istio-system -o jsonpath={.items..metadata.name})
echo "tail log from istiod_pod($istiod_pod)"
k logs -f "$istiod_pod" -c discovery -n istio-system