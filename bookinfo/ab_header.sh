#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias m="kubectl --kubeconfig $MESH_CONFIG"
alias k="kubectl --kubeconfig $USER_CONFIG"

echo "deploy control plane"
m apply -f header/

# 浏览器验证

# productpage日志
# echo "watching productpage log"
# productpage_pod=$(k get pod -l app=productpage -o jsonpath='{.items[0].metadata.name}')
# k logs -f $productpage_pod -c productpage 