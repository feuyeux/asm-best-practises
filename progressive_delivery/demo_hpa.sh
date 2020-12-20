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

## hpa
echo "deploy kube-metrics-adapter"
cd $KUBE_METRICS_ADAPTER_SRC/deploy/charts
h -n kube-system install asm-custom-metrics ./kube-metrics-adapter --set prometheus.url=http://prometheus.istio-system.svc:9090
echo "verify"
k get po -n kube-system |grep metrics-adapter

k api-versions |grep "autoscaling/v2beta"
k get --raw "/apis/external.metrics.k8s.io/v1beta1" | jq .

# loadtester
echo "deploy loadtester"
cd $FLAAGER_SRC
k apply -f kustomize/tester/deployment.yaml -n test
k apply -f kustomize/tester/service.yaml -n test
loadtester=$(k -n test get pod -l "app=flagger-loadtester" -o jsonpath='{.items..metadata.name}')
k -n test exec -it ${loadtester} -c loadtester -- hey -z 5m -c 10 -q 2 http://podinfo:9898

# hpa
k delete -f resources_hpa/requests_total_hpa.yaml
k apply -f resources_hpa/requests_total_hpa.yaml
k get --raw "/apis/external.metrics.k8s.io/v1beta1" | jq .

adapter_pod=$(k -n kube-system get pod -l "app=kube-metrics-adapter" -o jsonpath='{.items..metadata.name}')
k -n kube-system logs $adapter_pod --tail=10

#
loadtester=$(k -n test get pod -l "app=flagger-loadtester" -o jsonpath='{.items..metadata.name}')
k -n test exec -it ${loadtester} -c loadtester -- hey -z 10m -c 10 -q 2 http://podinfo:9898

#
watch kubectl --kubeconfig $USER_CONFIG -n test get hpa/podinfo