#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../tracing.config
alias k="kubectl --kubeconfig $USER_CONFIG"

echo "enable access log for ack cluster"
CLUSTER_ID=$(head -n 1 "$CLUSTERID_CONFIG")
sed "s/\${K8SClusterID}/$CLUSTER_ID/g" logtail-envoy-accesslog.tmpl.yaml | k apply -f -
echo
echo "enable ingress log"
k apply -f logtail-ingress-log.tmpl.yaml
echo
echo "check crd"
k get aliyunlogconfig -n kube-system