#!/usr/bin/env sh

export istio_version=1.7.8
export SKYWALKING_RELEASE_NAME=skywalking
export SKYWALKING_RELEASE_NAMESPACE=istio-system
# https://hub.docker.com/r/apache/skywalking-oap-server/tags?page=1&ordering=last_updated
export oap_image_tag=8.3.0-es7
export ui_image_tag=8.3.0
export skywalking_kubernetes_home=~/cooding/github/skywalking-kubernetes
export PATH=$PATH:~/shop/istio-${istio_version}/bin

alias k="kubectl --kubeconfig ~/shop_config/kubeconfig/istio-remote"
alias i="istioctl --kubeconfig ~/shop_config/kubeconfig/istio-remote"
alias h="helm --kubeconfig ~/shop_config/kubeconfig/istio-remote"

i manifest install -n \
    --set meshConfig.enableEnvoyAccessLogService=true \
    --set meshConfig.defaultConfig.envoyAccessLogService.address=skywalking-oap.istio-system:11800

# i install -y --set profile=demo \
#     --set meshConfig.enableEnvoyAccessLogService=true \
#     --set meshConfig.defaultConfig.envoyAccessLogService.address=skywalking-oap.${SKYWALKING_RELEASE_NAMESPACE}:11800

cd ${skywalking_kubernetes_home}
git co v4.0.0
cd chart
h repo add elastic https://helm.elastic.co
echo "Update dependencies"
h dep up skywalking >/dev/null 2>&1
echo "Deploy SkyWalking"
h install "${SKYWALKING_RELEASE_NAME}" skywalking -n "${SKYWALKING_RELEASE_NAMESPACE}" \
    --set oap.storageType='h2' \
    --set oap.image.tag=${oap_image_tag} \
    --set ui.image.tag=${ui_image_tag} \
    --set oap.replicas=1 \
    --set oap.env.SW_ENVOY_METRIC_ALS_HTTP_ANALYSIS=k8s-mesh \
    --set oap.env.JAVA_OPTS='-Dmode=' \
    --set oap.envoy.als.enabled=true \
    --set elasticsearch.enabled=false

k wait --for=condition=Ready pods --all --timeout=120s

export POD_NAME=$(k get pods -A -l "app=skywalking,release=skywalking,component=ui" -o name)
echo "skywalking oap pod=$POD_NAME"
k -n istio-system port-forward $POD_NAME 8080:8080

# k  -n istio-system logs $(k get pod -A -l "app=skywalking,release=skywalking,component=oap" -o name) 
