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

echo "==== Create files to transfer to the virtual machine ===="
echo "1 Create a template WorkloadGroup for the VM(s)"
i x workload group create --name "${VM_APP}" --namespace "${VM_NAMESPACE}" --labels app="${VM_APP}" \
--serviceAccount "${SERVICE_ACCOUNT}" > ${WORK_DIR}/workloadgroup.yaml
echo "2 Use the istioctl x workload entry command to generate"
i x workload entry configure -f ${WORK_DIR}/workloadgroup.yaml -o "${WORK_DIR}"

echo "==== Configure the virtual machine ===="
scp ${WORK_DIR}/* root@"$VM":/root/
scp run_on_vm.sh root@"$VM":/root/
scp test_sample_on_vm.sh root@"$VM":/root/

# only for avp(asm-vm-proxy)
ssh root@"$VM" "mkdir -p /opt/asm_vm_proxy/meta"
scp /opt/asm_vm_proxy/asm_vm_proxy.env root@"$VM":/opt/asm_vm_proxy/asm_vm_proxy.env
scp "$USER_CONFIG" root@"$VM":/opt/asm_vm_proxy/kubeconfig
scp run_avp_on_vm.sh root@"$VM":/root/