#!/usr/bin/env sh

set -e
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias k="kubectl --kubeconfig $USER_CONFIG"
k create namespace sample
k label namespace sample istio-injection=enabled

version=1.8.3
export ISTIO_HOME=${HOME}/shop/istio-${version}
k apply -n sample -f ${ISTIO_HOME}/samples/helloworld/helloworld.yaml