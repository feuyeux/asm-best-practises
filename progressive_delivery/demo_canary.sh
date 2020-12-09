#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

echo $SCRIPT_PATH

source config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"
alias h="helm --kubeconfig $USER_CONFIG"

# flagger
cd $FLAAGER_SRC
k -n istio-system create secret generic istio-kubeconfig --from-file $MESH_CONFIG
k -n istio-system label secret istio-kubeconfig  istio/multiCluster=true
k -n istio-system get secret istio-kubeconfig -o yaml

h repo add flagger https://flagger.app
h repo update
k apply -f artifacts/flagger/crd.yaml
h upgrade -i flagger flagger/flagger --namespace=istio-system \
--set crd.create=false \
--set meshProvider=istio \
--set metricsServer=http://prometheus:9090 \
--set istio.kubeconfig.secretName=istio-kubeconfig \
--set istio.kubeconfig.key=kubeconfig

# setup
k create ns test
k label namespace test istio-injection=enabled
m create ns test
m label namespace test istio-injection=enabled

k apply -k $FLAAGER_SRC/kustomize/podinfo
k apply -k $FLAAGER_SRC/kustomize/tester

# https://docs.flagger.app/v/master/tutorials/prometheus-operator
k apply -f $SCRIPT_PATH/service_monitor.yaml
k apply -f $SCRIPT_PATH/metrics_requests_error_rate.yaml
k apply -f $SCRIPT_PATH/metrics_latency.yaml
k apply -f $SCRIPT_PATH/podinfo-canary.yaml

k -n test get svc,pod,hpa

# verify
k -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.1
k -n test describe canary/podinfo

m -n test get virtualservice,destinationrule

watch kubectl --kubeconfig $USER_CONFIG get canaries --all-namespaces

k -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.2




###########



k -n test exec -it  -- 

export loadtester=$(kubectl -n test get pod -l "app=loadtester" -o jsonpath='{.items[0].metadata.name}')
kubectl -n test exec -it ${loadtester} -- hey -z 5s -c 10 -q 2 http://podinfo.test:9898

# hpa
cd $SCRIPT_PATH
k apply -f progressive_delivery/requests_total_hpa.yaml -n mixerless


# canary bootstrap

k create ns progressive_delivery




k delete ns test
m delete ns test