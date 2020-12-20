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

install_flagger_on_asm() {
  echo "Deploy flagger"
  cd $FLAAGER_SRC
  k -n istio-system create secret generic istio-kubeconfig --from-file $MESH_CONFIG
  k -n istio-system label secret istio-kubeconfig istio/multiCluster=true
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

  echo "Deploy public-gateway"
  m apply -f resources_canary/public-gateway.yaml
}

setup_test() {
  echo "Setup test namespace"
  k delete ns test
  m delete ns test
  k create ns test
  k label namespace test istio-injection=enabled
  m create ns test
  m label namespace test istio-injection=enabled
}

# flagger
# install_flagger_on_asm

# setup
setup_test

echo "Create a deployment and a horizontal pod autoscaler"
k apply -k $FLAAGER_SRC/kustomize/podinfo
#loader
echo "Deploy the load testing service(flagger-loadtester) to generate traffic during the canary analysis"
k apply -k $FLAAGER_SRC/kustomize/tester

# canary
echo "Deploy canary resources"
k apply -f resources_canary/podinfo-canary.yaml
#
# https://docs.flagger.app/v/master/tutorials/prometheus-operator
# k apply -f $SCRIPT_PATH/service_monitor.yaml
# k apply -f $SCRIPT_PATH/metrics_requests_error_rate.yaml
# k apply -f $SCRIPT_PATH/metrics_latency.yaml
# k apply -f $SCRIPT_PATH/podinfo-canary.yaml
echo "Waiting 15s"
sleep 15s
echo "Verify"
k -n test get svc,pod,hpa
sleep 15s

echo "Start load"
loadtester=$(k -n test get pod -l "app=flagger-loadtester" -o jsonpath='{.items..metadata.name}')
k -n test exec -it ${loadtester} -c loadtester -- hey -z 20m -c 10 -q 2 http://podinfo:9898 &

sleep 15s

echo "Change deployment/podinfo to 3.1.1"
k -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.1

sleep 30s
m -n test get virtualservice,destinationrule

# verify canary
# k -n test describe canary/podinfo

# watch kubectl --kubeconfig $USER_CONFIG get canaries --all-namespaces

# https://flagger.app/intro/faq.html#metrics
prometheus_lb=$(k get svc -n istio-system -l app=prometheus -o jsonpath="{.items..status.loadBalancer.ingress[0].ip}")
echo "http://$prometheus_lb:9090"



###########
# k -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.2
