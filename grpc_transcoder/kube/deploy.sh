#!/usr/bin/env bash
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit

alias k="kubectl --kubeconfig ~/shop_config/ack_cd"
alias m="kubectl --kubeconfig ~/shop_config/asm_cd"
#alias m="~/shop/istio-1.8.1/bin/istioctl --kubeconfig ~/shop_config/ack_istio"

k create ns grpc-best
m create ns grpc-best
m label ns grpc-best istio-injection=enabled

k apply -f $HOME/cooding/alibaba/hello-servicemesh-grpc/kube/grpc-sa.yaml
k apply -f $HOME/cooding/alibaba/hello-servicemesh-grpc/kube/deployment/grpc-server-java.yaml
k apply -f $HOME/cooding/alibaba/hello-servicemesh-grpc/kube/grpc-svc.yaml

m apply -f $HOME/cooding/alibaba/hello-servicemesh-grpc/mesh/grpc-gw.yaml
m apply -f $HOME/cooding/alibaba/hello-servicemesh-grpc/mesh/grpc-vs-v1-100.yaml
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

k apply -f $HOME/cooding/alibaba/hello-servicemesh-grpc/kube/deployment/grpc-client-java.yaml
#k exec grpc-server-java-79d55dd884-zdksq -n grpc-best -c grpc-server-deploy -- ps aux
#m proxy-status
#m proxy-config listeners "$pod.istio-system"