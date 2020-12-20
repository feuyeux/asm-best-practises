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

# 确认勾选开启采集Prometheus监控指标并生成envoyfilter
m get envoyfilter -n istio-system

# 部署prometheus
cd $ISTIO_SRC/samples/addons
k apply -f prometheus.yaml
# 部署grafana
k apply -f grafana.yaml

# scraping configurations
#echo ../test/scrape_configs.yaml
#k edit cm prometheus -n istio-system

## ==================================== ##
# init test
k create ns test
k label namespace test istio-injection=enabled
m create ns test
m label namespace test istio-injection=enabled

# init podinfo
cd $PODINFO_SRC
k apply -f kustomize/deployment.yaml -n test
k apply -f kustomize/service.yaml -n test
podinfo_pod=$(k get po -n test -l app=podinfo -o jsonpath={.items..metadata.name})
echo "podinfo_pod=$podinfo_pod"

cd $SCRIPT_PATH
m apply -f resources_test/podinfo_gateway.yaml -n test

# expose 9898
k get svc/istio-ingressgateway -n istio-system -owide

# ingress-gateway
ingress_gateway=$(k get svc/istio-ingressgateway -n istio-system | awk '{print $4}' | awk 'NR==2{print}')
curl $ingress_gateway:9898/version

# envoy metrics
k exec $podinfo_pod -n test -c istio-proxy -- curl -s localhost:15090/stats/prometheus |grep istio_requests_total
k exec $podinfo_pod -n test -c istio-proxy -- curl -s localhost:15090/stats/prometheus |grep istio_request_duration

#######################
k scale --replicas=2 deploy/podinfo -n test

podinfo_pod1=$(k get po -n test -l app=podinfo -o jsonpath="{.items[0].metadata.name}")
podinfo_pod2=$(k get po -n test -l app=podinfo -o jsonpath="{.items[1].metadata.name}")

k exec $podinfo_pod1 -n test -c istio-proxy -- curl -s localhost:15090/stats/prometheus |grep istio_request_duration
k exec $podinfo_pod2 -n test -c istio-proxy -- curl -s localhost:15090/stats/prometheus |grep istio_request_duration
