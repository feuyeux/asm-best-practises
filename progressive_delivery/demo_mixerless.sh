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

#
# k delete -f $ISTIO_SRC/samples/addons/prometheus.yaml
k apply -f $ISTIO_SRC/samples/addons/prometheus.yaml
k get po -n istio-system

# ../mixerless/scrape_configs.yaml

# 部署prometheus (mixerless telemetry scrape)

# https://istio.io/latest/docs/ops/integrations/prometheus/
# To simplify configuration, Istio has the ability to control scraping entirely by prometheus.io annotations.
# This allows Istio scraping to work out of the box with standard configurations
# such as the ones provided by the Helm stable/prometheus charts.
#
# h uninstall prometheus --namespace istio-system
# h install prometheus $ISTIO_SRC/manifests/charts/istio-telemetry/prometheus \
#   --set meshConfig.enablePrometheusMerge=false \
#   --set meshConfig.defaultConfig.proxyMetadata.DNS_AGENT="" \
#   --namespace istio-system

# 部署grafana
k apply -f $ISTIO_SRC/samples/addons/grafana.yaml

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
k apply -f $PODINFO_SRC/kustomize/deployment.yaml -n test
k apply -f $PODINFO_SRC/kustomize/service.yaml -n test
podinfo_pod=$(k get po -n test -l app=podinfo -o jsonpath={.items..metadata.name})
echo "podinfo_pod=$podinfo_pod"

# expose 9898
k get svc/istio-ingressgateway -n istio-system -owide

# ingress-gateway
ingress_gateway=$(k get svc/istio-ingressgateway -n istio-system | awk '{print $4}' | awk 'NR==2{print}')
curl $ingress_gateway:9898/version

# envoy metrics
k exec $podinfo_pod -n test -c istio-proxy -- curl -s localhost:15090/stats/prometheus | grep istio_requests_total
k exec $podinfo_pod -n test -c istio-proxy -- curl -s localhost:15090/stats/prometheus | grep istio_request_duration
