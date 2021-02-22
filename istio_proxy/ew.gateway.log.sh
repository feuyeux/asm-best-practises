#!/usr/bin/env sh
set -e
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source config
alias k="kubectl --kubeconfig $USER_CONFIG"
ew_pod=$(k get pod -l app=istio-eastwestgateway -n istio-system -o jsonpath={.items..metadata.name})
echo "tail log from ew_pod($ew_pod)"
k logs -f "$ew_pod" -c istio-proxy -n istio-system

# tls-istiod 15012