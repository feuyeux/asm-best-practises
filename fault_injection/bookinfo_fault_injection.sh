MESH_CONFIG=~/shop_config/bj_mesh_config
USER_CONFIG=~/shop_config/bj_config
ISTIO_HOME=~/shop/istio-1.6.3

GatewayUrl() {
  INGRESS_HOST=$(kubectl --kubeconfig "$USER_CONFIG" \
    -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  # config should has `http2`
  INGRESS_PORT=$(kubectl --kubeconfig "$USER_CONFIG" \
    -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

  echo "$INGRESS_HOST":"$INGRESS_PORT"
}
CleanUpBookInfoApplication() {
  kubectl --kubeconfig "$USER_CONFIG" \
    delete -f $ISTIO_HOME/samples/bookinfo/platform/kube/bookinfo.yaml >/dev/null 2>&1
  kubectl --kubeconfig "$MESH_CONFIG" \
    delete -f $ISTIO_HOME/samples/bookinfo/networking/bookinfo-gateway.yaml >/dev/null 2>&1
  kubectl --kubeconfig "$MESH_CONFIG" \
    delete -f $ISTIO_HOME/samples/bookinfo/networking/destination-rule-all.yaml >/dev/null 2>&1
}

DeployBookInfoApplication() {
  kubectl --kubeconfig "$USER_CONFIG" \
    label namespace default istio-injection=enabled >/dev/null 2>&1
  kubectl --kubeconfig "$USER_CONFIG" \
    apply -f $ISTIO_HOME/samples/bookinfo/platform/kube/bookinfo.yaml

  kubectl --kubeconfig "$USER_CONFIG" wait --for=condition=ready pod -l app=productpage
  kubectl --kubeconfig "$USER_CONFIG" wait --for=condition=ready pod -l app=reviews
  kubectl --kubeconfig "$USER_CONFIG" wait --for=condition=ready pod -l app=ratings
  kubectl --kubeconfig "$USER_CONFIG" wait --for=condition=ready pod -l app=details

  pod=$(kubectl \
    --kubeconfig "$USER_CONFIG" \
    get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')

  RESULT=$(kubectl \
    --kubeconfig "$USER_CONFIG" \
    exec -it "$pod" -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>")

  if [[ $RESULT != "<title>Simple Bookstore App</title>" ]]; then
    echo "Unexpected result:$RESULT"
    exit
  fi

  kubectl --kubeconfig "$MESH_CONFIG" \
    apply -f $ISTIO_HOME/samples/bookinfo/networking/bookinfo-gateway.yaml
  kubectl --kubeconfig "$MESH_CONFIG" \
    apply -f $ISTIO_HOME/samples/bookinfo/networking/destination-rule-all.yaml

  GATEWAY_URL=$(GatewayUrl)

  RESULT=$(curl -s "http://${GATEWAY_URL}/productpage" | grep -o "<title>.*</title>")
  if [[ $RESULT != "<title>Simple Bookstore App</title>" ]]; then
    echo "Unexpected result:$RESULT"
    exit
  fi
  echo "Done"
}

# https://istio.io/latest/docs/tasks/traffic-management/fault-injection/
# productpage (retry 3s + 1 time = 6s)→ reviews:v2 (timeout 10s)→ ratings (only for user jason) (delay 7s)
# productpage → reviews:v1 (for everyone else)
FaultInjection() {
  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    apply -f $ISTIO_HOME/samples/bookinfo/networking/virtual-service-all-v1.yaml
  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    apply -f $ISTIO_HOME/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml
  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    apply -f $ISTIO_HOME/samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml

  GATEWAY_URL=$(GatewayUrl)
  echo "http://${GATEWAY_URL}/productpage"

  # login as jason
  # Sorry, product reviews are currently unavailable for this book.
}

# CleanUpBookInfoApplication
DeployBookInfoApplication
FaultInjection
