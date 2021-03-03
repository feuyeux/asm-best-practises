#!/usr/bin/env bash
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
. config.env
alias k="kubectl --kubeconfig $ACK_KUBECONFIG"
alias m="kubectl --kubeconfig $ASM_KUBECONFIG"
#alias m="~/shop/istio-1.8.1/bin/istioctl --kubeconfig ~/shop_config/ack_istio"

k create ns grpc-best
m create ns grpc-best
m label ns grpc-best istio-injection=enabled

k apply -f $HELLO_GRPC_HOME/kube/grpc-sa.yaml
k apply -f $HELLO_GRPC_HOME/kube/deployment/grpc-with-api-server-java.yaml
k apply -f $HELLO_GRPC_HOME/kube/grpc-svc.yaml

m apply -f $HELLO_GRPC_HOME/mesh/grpc-gw.yaml
m apply -f $HELLO_GRPC_HOME/mesh/grpc-vs-v1-100.yaml
cat <<EOF | m apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  namespace: grpc-best
  name: grpc-server-dr
spec:
  host: grpc-server-svc
  subsets:
    - name: v1
      labels:
        version: v1
EOF

k apply -f $HELLO_GRPC_HOME/kube/deployment/grpc-with-api-client-java.yaml
#k exec grpc-server-java-79d55dd884-zdksq -n grpc-best -c grpc-server-deploy -- ps aux
#m proxy-status
#m proxy-config listeners "$pod.istio-system"