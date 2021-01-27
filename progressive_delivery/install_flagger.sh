#!/usr/bin/env sh
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"
alias h="helm --kubeconfig $USER_CONFIG"

echo "1 Install Flagger in the istio-system namespace[kustomize]:"
# Note that the Istio kubeconfig must be stored in a Kubernetes secret with a data key named kubeconfig. 
cp $MESH_CONFIG kubeconfig
# k -n istio-system delete secret istio-kubeconfig
k -n istio-system create secret generic istio-kubeconfig --from-file kubeconfig
# k -n istio-system get secret istio-kubeconfig -o yaml

k -n istio-system label secret istio-kubeconfig istio/multiCluster=true

h repo add flagger https://flagger.app
h repo update
k apply -f $FLAAGER_SRC/artifacts/flagger/crd.yaml

## https://github.com/fluxcd/flagger/blob/main/charts/flagger/values.yaml
## docker tag ghcr.io/fluxcd/flagger:1.6.1 registry.cn-beijing.aliyuncs.com/asm_repo/flagger:1.6.1
h upgrade -i flagger flagger/flagger --namespace=istio-system \
    --set crd.create=false \
    --set meshProvider=istio \
    --set metricsServer=http://prometheus:9090 \
    --set istio.kubeconfig.secretName=istio-kubeconfig \
    --set istio.kubeconfig.key=kubeconfig
    # --set image.repository=registry.cn-beijing.aliyuncs.com/asm_repo/flagger
k get pod -n istio-system

echo "2 Create an ingress gateway to expose the demo app outside of the mesh:"
m apply -f resources_canary/public-gateway.yaml

echo