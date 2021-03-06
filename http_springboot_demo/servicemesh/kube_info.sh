#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"

v3_pod=$(k get pod -l app=http-hello-deploy -n http-hello -o jsonpath='{.items[2].metadata.name}')
k -n http-hello get pod "$v3_pod" -o yaml >"/tmp/$v3_pod.yaml"

printf "/var/run/secrets/istio/ (istiod-ca-cert)\n"
k exec "$v3_pod" -c istio-proxy -n http-hello -- ls -al /var/run/secrets/istio

printf "\n/etc/istio/proxy (istio-envoy)\n"
k exec "$v3_pod" -c istio-proxy -n http-hello -- ls -al /etc/istio/proxy

printf "\nenvoy-rev0.json\n"
k exec "$v3_pod" -c istio-proxy -n http-hello -- cat /etc/istio/proxy/envoy-rev0.json

printf "\n/etc/istio/pod (istio-podinfo)\n"
k exec "$v3_pod" -c istio-proxy -n http-hello -- ls -al /etc/istio/pod

printf "\n/var/lib/istio/data (istio-data)\n"
k exec "$v3_pod" -c istio-proxy -n http-hello -- ls -al /var/lib/istio/data

printf "\n/var/run/secrets/kubernetes.io/serviceaccount (http-hello-sa-token-6zvb7)\n"
k exec "$v3_pod" -c istio-proxy -n http-hello -- ls -al /var/run/secrets/kubernetes.io/serviceaccount

#### login
USER_CONFIG=~/shop_config/ack_zjk_cluster
alias k="kubectl --kubeconfig $USER_CONFIG"
v3_pod=$(k get pod -l app=http-hello-deploy -n http-hello -o jsonpath='{.items[2].metadata.name}')
k exec -it "$v3_pod" -c istio-proxy -n http-hello -- /bin/bash
