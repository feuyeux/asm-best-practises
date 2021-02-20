#!/usr/bin/env sh
set -e
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
version=1.8.3
export ISTIO_HOME=${HOME}/shop/istio-${version}
export VM_APP=vm-app
export VM_NAMESPACE=vm-namespace
export WORK_DIR=work_dir
export SERVICE_ACCOUNT=vm-sa

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

echo "==== Create files to transfer to the virtual machine ===="
echo "1 Create a template WorkloadGroup for the VM(s)"
i x workload group create --name "${VM_APP}" --namespace "${VM_NAMESPACE}" --labels app="${VM_APP}" --serviceAccount "${SERVICE_ACCOUNT}" > workloadgroup.yaml
echo "2 Use the istioctl x workload entry command to generate"
i x workload entry configure -f workloadgroup.yaml -o "${WORK_DIR}"

echo "==== Configure the virtual machine ===="
scp ${WORK_DIR}/* root@"$VM":/root/
scp run_on_vm.sh root@"$VM":/root/
scp test_sample_on_vm.sh root@"$VM":/root/