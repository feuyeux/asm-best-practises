#!/usr/bin/env sh

alias k="kubectl --kubeconfig ~/shop_config/kubeconfig/istio-primary"
k apply -f samples/addons/kiali.yaml
echo "========\n"
kiali_pod=$(k get pod -l app=kiali -n istio-system -o jsonpath='{.items[0].metadata.name}')
k exec $kiali_pod -n istio-system -- cat /var/run/secrets/kubernetes.io/serviceaccount/token >  /var/run/secrets/kubernetes.io/serviceaccount/token
cat /var/run/secrets/kubernetes.io/serviceaccount/token