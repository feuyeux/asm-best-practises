#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source tracing.config
kubectl --kubeconfig "$KUBECONFIG" apply -f zipkin-server.yaml
kubectl --kubeconfig "$KUBECONFIG" -n istio-system wait --for=condition=ready pod -l app=zipkin-server
kubectl --kubeconfig "$KUBECONFIG" apply -f zipkin-service.yaml
zipkin_ip=$(kubectl --kubeconfig "$KUBECONFIG" get svc -n istio-system|grep zipkin|awk -F ' ' '{print $4}')
echo "http://$zipkin_ip:9411/"