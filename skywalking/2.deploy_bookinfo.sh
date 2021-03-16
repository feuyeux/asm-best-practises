#!/usr/bin/env sh
export istio_version=1.7.8
alias k="kubectl --kubeconfig ~/shop_config/kubeconfig/istio-remote"
export ISTIO_HOME=~/shop/istio-${istio_version}
##
# k label ns default istio-injection=enabled >/dev/null 2>&1
# k delete -f ${ISTIO_HOME}/samples/bookinfo/platform/kube/bookinfo.yaml >/dev/null 2>&1
# k delete -f ${ISTIO_HOME}/samples/bookinfo/networking/bookinfo-gateway.yaml >/dev/null 2>&1
##
k apply -f ${ISTIO_HOME}/samples/bookinfo/platform/kube/bookinfo.yaml
k apply -f ${ISTIO_HOME}/samples/bookinfo/networking/bookinfo-gateway.yaml
k wait --for=condition=Ready pods --all --timeout=120s
ratings_pod=$(k get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')
k exec ${ratings_pod} -c ratings -- curl -s productpage:9080/productpage | grep -o "<title>.*</title>"
GATEWAY_URL=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# k get gw -oyaml
# k get vs -oyaml
echo "http://${GATEWAY_URL}/productpage"
