#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

echo "1 make sure about envoyfilters"
m get envoyfilter -n istio-system

echo "2 deploy prometheus"
# k delete -f $ISTIO_SRC/samples/addons/prometheus.yaml
k apply -f $ISTIO_SRC/samples/addons/prometheus.yaml

echo "3 make sure about prometheus config"
# 请使用 ../mixerless/scrape_configs.yaml
k get cm prometheus -n istio-system -o jsonpath={.data.prometheus\\.yml} | grep job_name

## ==================================== ##
echo "4 init test namespace"
k create ns test
k label namespace test istio-injection=enabled
m create ns test
m label namespace test istio-injection=enabled

echo "5 init podinfo pod"
k apply -f $PODINFO_SRC/kustomize/deployment.yaml -n test
k apply -f $PODINFO_SRC/kustomize/service.yaml -n test

echo "6 access to generate metrics data"
podinfo_pod=$(k get po -n test -l app=podinfo -o jsonpath={.items..metadata.name})
echo "podinfo_pod=$podinfo_pod"
for i in {1..10}; do
   k exec $podinfo_pod -c podinfod -n test -- curl -s podinfo:9898/version
  echo
done

echo "7 check metrics data from envoy"
echo ":::: istio_requests_total ::::"
k exec $podinfo_pod -n test -c istio-proxy -- curl -s localhost:15090/stats/prometheus | grep istio_requests_total
echo ":::: istio_request_duration ::::"
k exec $podinfo_pod -n test -c istio-proxy -- curl -s localhost:15090/stats/prometheus | grep istio_request_duration