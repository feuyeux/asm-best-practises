source config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias h="helm --kubeconfig $USER_CONFIG"

k -n istio-system create secret generic istio-kubeconfig --from-file $MESH_CONFIG

# h template flagger $FLAAGER_SRC/charts/flagger \
# --namespace=istio-system \
# --set meshProvider=istio \
# --set istio.kubeconfig.secretName=istio-kubeconfig \
# --set metricsServer=http://ack-prometheus-operator-prometheus:9090 \
# --set istio.kubeconfig.key=kubeconfig > flagger.yaml
# k install -f flagger.yaml -n istio-system


# h repo add flagger https://flagger.app
# h repo update
# k apply -f $FLAAGER_SRC/artifacts/flagger/crd.yaml
# h upgrade -i flagger flagger/flagger \
# --namespace=istio-system \
# --set crd.create=false \
# --set meshProvider=istio \
# --set metricsServer=http://istio-cluster-prometheus:9090 \
# --set istio.kubeconfig.secretName=istio-kubeconfig \
# --set istio.kubeconfig.key=kubeconfig
h delete flagger
k delete crd canaries.flagger.app