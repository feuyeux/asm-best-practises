#!/usr/bin/env bash
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
. ../kube/config.env
alias k="kubectl --kubeconfig $ACK_KUBECONFIG"
alias m="kubectl --kubeconfig $ASM_KUBECONFIG"

dump() {
    if [ ! $2 ]; then
        ns="default"
    else
        ns=$2
    fi
    pod=$(k get pod -l app="$1" -n $ns -o jsonpath='{.items[0].metadata.name}')
    echo "\ndump $1 -ns=$ns pod=$pod"
    # k -n $ns exec $pod \
    #     -c istio-proxy \
    #     -- curl -s "http://localhost:15000/config_dump?resource=static_listeners" >static_listeners-"$3".json
    k -n $ns exec $pod \
        -c istio-proxy \
        -- curl -s "http://localhost:15000/config_dump?dynamic_listeners" >dynamic_listeners-"$3".json
    # k -n $ns exec $pod \
    #     -c istio-proxy \
    #     -- curl -s "http://localhost:15000/config_dump" >config_dump-"$3".json
}

apply() {
    echo "apply yaml files to istio-system"
    m apply -f $GRPC_TRANSCODER_HOME/grpc-transcoder-envoyfilter.yaml -n istio-system

    # no need
    #m apply -f $GRPC_TRANSCODER_HOME/header2metadata-envoyfilter.yaml -n istio-system
    sleep 10s
}

apply

rm -rf *json
timestamp=$(date "+%Y%m%d-%H%M%S")
dump istio-ingressgateway istio-system "$timestamp"
echo "grep:"
grep -B3 -A7 GrpcJsonTranscoder dynamic_listeners-"$timestamp".json
# k delete envoyfilter grpc-transcoder -n istio-system
