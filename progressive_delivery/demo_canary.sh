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

install_flagger_on_asm() {
  echo "Deploy flagger"
  # flagger
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

# install_flagger_on_asm

# setup
setup_test
# podinfo
echo "Create a deployment and a horizontal pod autoscaler"
k apply -k $FLAAGER_SRC/kustomize/podinfo
#loader
echo "Deploy the load testing service(flagger-loadtester) to generate traffic during the canary analysis"
k apply -k $FLAAGER_SRC/kustomize/tester
sleep 15s
k -n test wait --for=condition=ready pod -l app=flagger-loadtester
k -n test get svc,pod

###########################################################################################################
# k apply -f $PODINFO_SRC/kustomize/service.yaml -n test
# podinfo_pod1=$(k get po -n test -l app=podinfo -o jsonpath="{.items[0].metadata.name}")
# podinfo_pod2=$(k get po -n test -l app=podinfo -o jsonpath="{.items[1].metadata.name}")
# # https://github.com/stefanprodan/podinfo
# loadtester=$(k -n test get pod -l "app=flagger-loadtester" -o jsonpath='{.items..metadata.name}')
# k -n test exec -it ${loadtester} -c loadtester -- curl -sI podinfo:9898/version
# k -n test exec -it ${loadtester} -c loadtester -- hey -z 20m -c 10 -q 2 http://podinfo:9898/version
# k exec $podinfo_pod1 -n test -c istio-proxy -- curl -s localhost:15090/stats/prometheus | grep istio_requests_total
# k exec $podinfo_pod2 -n test -c istio-proxy -- curl -s localhost:15090/stats/prometheus | grep istio_request_duration
# k delete -f $PODINFO_SRC/kustomize/service.yaml -n test
###########################################################################################################

# canary
echo "Deploy canary resources"
k apply -f resources_canary/podinfo-canary.yaml
sleep 15s

echo "Change deployment/podinfo to 3.1.1"
k -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.1
sleep 15s

# verify canary
for ((i = 1; i <= 30; i++)); do
  k -n test describe canary/podinfo
  sleep 10s
done

###############################################################################

m -n test get virtualservice,destinationrule

m -n test get virtualservice podinfo -o jsonpath="{.spec.http..route[0].weight}"
m -n test get virtualservice podinfo -o jsonpath="{.spec.http..route[1].weight}"

watch kubectl --kubeconfig $USER_CONFIG get canaries --all-namespaces

# https://flagger.app/intro/faq.html#metrics
# prometheus_lb=$(k get svc -n istio-system -l app=prometheus -o jsonpath="{.items..status.loadBalancer.ingress[0].ip}")
# echo "http://$prometheus_lb:9090"

###########
# k -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.2
