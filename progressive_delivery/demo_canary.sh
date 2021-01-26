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

echo "3 Create an ingress gateway to expose the demo app outside of the mesh:"
m apply -f resources_canary/public-gateway.yaml

echo
echo "#### II Bootstrap ####"

echo "1 Create a test namespace with Istio sidecar injection enabled:"
k create ns test
m create ns test
m label namespace test istio-injection=enabled

echo "2 Create a deployment and a horizontal pod autoscaler:"
k apply -k "https://github.com/fluxcd/flagger//kustomize/podinfo?ref=main"

echo "3 Deploy the load testing service to generate traffic during the canary analysis:"
k apply -k "https://github.com/fluxcd/flagger//kustomize/tester?ref=main"

echo "4 Create a canary custom resource:"
k apply -f resources_canary/podinfo-canary.yaml

echo
echo "#### III Automated canary promotion ####"

echo "1 Trigger a canary deployment by updating the container image:"
k -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.1

echo "2 Flagger detects that the deployment revision changed and starts a new rollout:"

while true; do k -n test describe canary/podinfo; sleep 10s;done

# Events:
#   Type    Reason  Age   From     Message
#   ----    ------  ----  ----     -------
#   Normal  Synced  6m8s  flagger  New revision detected! Scaling up podinfo.test
#   Normal  Synced  5m8s  flagger  New revision detected! Restarting analysis for podinfo.test
#   Normal  Synced  4m8s  flagger  Starting canary analysis for podinfo.test
#   Normal  Synced  4m8s  flagger  Pre-rollout check acceptance-test passed
#   Normal  Synced  4m7s  flagger  Advance podinfo.test canary weight 10
#   Normal  Synced  3m8s  flagger  Advance podinfo.test canary weight 20
#   Normal  Synced  2m8s  flagger  Advance podinfo.test canary weight 30
#   Normal  Synced  68s   flagger  Advance podinfo.test canary weight 40
#   Normal  Synced  8s    flagger  Advance podinfo.test canary weight 50

# Events:
#   Type    Reason  Age               From     Message
#   ----    ------  ----              ----     -------
#   Normal  Synced  8m9s              flagger  New revision detected! Scaling up podinfo.test
#   Normal  Synced  7m9s              flagger  New revision detected! Restarting analysis for podinfo.test
#   Normal  Synced  6m9s              flagger  Starting canary analysis for podinfo.test
#   Normal  Synced  6m9s              flagger  Pre-rollout check acceptance-test passed
#   Normal  Synced  6m8s              flagger  Advance podinfo.test canary weight 10
#   Normal  Synced  5m9s              flagger  Advance podinfo.test canary weight 20
#   Normal  Synced  4m9s              flagger  Advance podinfo.test canary weight 30
#   Normal  Synced  3m9s              flagger  Advance podinfo.test canary weight 40
#   Normal  Synced  2m9s              flagger  Advance podinfo.test canary weight 50
#   Normal  Synced  9s (x2 over 69s)  flagger  (combined from similar events): Routing all traffic to primary

watch kubectl --kubeconfig istio-kubeconfig get canaries --all-namespaces

# Every 2.0s: kubectl --kubeconfig i...  East6C16G: Tue Jan 26 13:40:38 2021

# NAMESPACE   NAME      STATUS        WEIGHT   LASTTRANSITIONTIME
# test        podinfo   Progressing   50       2021-01-26T05:40:16Z


# Every 2.0s: kubectl --kubeconfig i...  East6C16G: Tue Jan 26 13:42:21 2021

# NAMESPACE   NAME      STATUS       WEIGHT   LASTTRANSITIONTIME
# test        podinfo   Finalising   0        2021-01-26T05:42:16Z
