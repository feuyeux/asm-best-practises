#!/usr/bin/env bash
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit

alias k="kubectl --kubeconfig ~/shop_config/ack_cd"
alias m="kubectl --kubeconfig ~/shop_config/asm_cd"

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

rm -rf *json
echo "apply yaml files to istio-system"
m apply -f grpc-transcoder-envoyfilter.yaml -n istio-system

# no need
#m apply -f header2metadata-envoyfilter.yaml -n istio-system

sleep 10s
timestamp=$(date "+%Y%m%d-%H%M%S")
dump istio-ingressgateway istio-system "$timestamp"
echo "grep:"
grep -B3 -A7 GrpcJsonTranscoder dynamic_listeners-"$timestamp".json
# k delete envoyfilter grpc-transcoder -n istio-system