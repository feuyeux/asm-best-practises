#!/usr/bin/env sh
set -e
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias i="${ISTIO_HOME}/bin/istioctl --kubeconfig $USER_CONFIG"

echo "=== Install the Istio control plane ===="
echo "1 Install Istio."
i install
echo "2 Deploy the east-west gateway:"
${ISTIO_HOME}/samples/multicluster/gen-eastwest-gateway.sh --single-cluster | i install -y -f -
echo "3 Expose the control plane using the provided sample configuration:"
k apply -f ${ISTIO_HOME}/samples/multicluster/expose-istiod.yaml

echo "=== Configure the VM namespace ===="
echo "1 Create the namespace that will host the virtual machine:"
k create namespace "${VM_NAMESPACE}"
echo "2 Create a serviceaccount for the virtual machine:"
k create serviceaccount "${SERVICE_ACCOUNT}" -n "${VM_NAMESPACE}"