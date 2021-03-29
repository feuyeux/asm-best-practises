#!/usr/bin/env sh
set -e
export skywalking_kubernetes_home=~/cooding/github/skywalking-kubernetes
export PATH=$PATH:~/shop/istio-${istio_version}/bin
alias h="helm --kubeconfig ~/shop_config/kubeconfig/istio-remote"

cd ${skywalking_kubernetes_home}
# git co v4.0.0

export SKYWALKING_RELEASE_NAME=skywalking
export SKYWALKING_RELEASE_NAMESPACE=istio-system
# https://hub.docker.com/r/apache/skywalking-oap-server/tags?page=1&ordering=last_updated
export OAP_IMAGE_TAG=8.4.0-es7
# https://hub.docker.com/r/apache/skywalking-ui/tags?page=1&ordering=last_updated
export UI_IMAGE_TAG=8.4.0

cd chart
h repo add elastic https://helm.elastic.co >/dev/null 2>&1
echo "Update dependencies"
# h dep up skywalking >/dev/null 2>&1

echo "Deploy SkyWalking"
######################
# export STORAGE_TYPE=h2
# h install "${SKYWALKING_RELEASE_NAME}" skywalking -n "${SKYWALKING_RELEASE_NAMESPACE}" \
#     --set oap.image.tag=${OAP_IMAGE_TAG} \
#     --set elasticsearch.enabled=false \
#     --set oap.storageType=${STORAGE_TYPE} \
#     --set ui.image.tag=${UI_IMAGE_TAG} \
#     --set oap.replicas=1 \
#     --set oap.env.SW_ENVOY_METRIC_ALS_HTTP_ANALYSIS=k8s-mesh \
#     --set oap.envoy.als.enabled=true
########################
export ES_IMAGE_TAG="7.9.3"
export STORAGE_TYPE=elasticsearch7
h install "${SKYWALKING_RELEASE_NAME}" skywalking -n "${SKYWALKING_RELEASE_NAMESPACE}" \
    --set oap.image.tag=${OAP_IMAGE_TAG} \
    --set oap.storageType=${STORAGE_TYPE} \
    --set ui.image.tag=${UI_IMAGE_TAG} \
    --set elasticsearch.imageTag=${ES_IMAGE_TAG} \
    --set oap.replicas=1 \
    --set oap.env.SW_ENVOY_METRIC_ALS_HTTP_ANALYSIS=k8s-mesh \
    --set oap.envoy.als.enabled=true

########
# alias k="kubectl --kubeconfig ~/shop_config/kubeconfig/ack_production"
# k wait --for=condition=Ready pods --all --timeout=120s

# export POD_NAME=$(k get pods -A -l "app=skywalking,release=skywalking,component=ui" -o name)
# echo "skywalking oap pod=$POD_NAME"
# k -n istio-system port-forward $POD_NAME 8080:8080

# k -n istio-system logs $(k get pod -A -l "app=skywalking,release=skywalking,component=oap" -o name) 
