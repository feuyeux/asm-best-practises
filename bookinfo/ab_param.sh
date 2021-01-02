#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

export ISTIO_HOME=${HOME}/shop/istio-1.7.5
alias k="kubectl --kubeconfig ${HOME}/shop/KUBE"
alias m="kubectl --kubeconfig ${HOME}/shop/MESH"