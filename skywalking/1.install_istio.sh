#!/usr/bin/env sh

export istio_version=1.7.8
export PATH=$PATH:~/shop/istio-${istio_version}/bin
alias k="kubectl --kubeconfig ~/shop_config/kubeconfig/istio-remote"
k delete ns istio-system
alias i="istioctl --kubeconfig ~/shop_config/kubeconfig/istio-remote"
i install -y --set profile=demo