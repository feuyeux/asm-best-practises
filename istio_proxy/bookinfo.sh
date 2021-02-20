#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
version=1.8.3
export ISTIO_HOME=${HOME}/shop/istio-${version}
source config
alias k="kubectl --kubeconfig $USER_CONFIG"
k label ns default istio-injection=enabled

#部署数据平面
# k delete -f ${ISTIO_HOME}/samples/bookinfo/platform/kube/bookinfo.yaml
k apply -f ${ISTIO_HOME}/samples/bookinfo/platform/kube/bookinfo.yaml
#查看服务状态
k get services
#查看POD状态
k get pods

while ! k wait --for=condition=ready --timeout=5s pod -l app=productpage; do sleep 1; done

#校验服务间的通信
ratings_pod=$(k get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')
k exec ${ratings_pod} -c ratings -- curl -s productpage:9080/productpage | grep -o "<title>.*</title>"

#部署控制平面
# m delete -f ${ISTIO_HOME}/samples/bookinfo/networking/bookinfo-gateway.yaml
k apply -f ${ISTIO_HOME}/samples/bookinfo/networking/bookinfo-gateway.yaml
#查看状态
k get gw
echo
k get vs

#入口网关
GATEWAY_URL=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

#验证
echo "http://${GATEWAY_URL}/productpage"
curl -I "http://${GATEWAY_URL}/productpage"
