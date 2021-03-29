#!/usr/bin/env sh
set -e
export istio_version=1.8.4
export PATH=$PATH:~/shop/istio-${istio_version}/bin
alias k="kubectl --kubeconfig ~/shop_config/kubeconfig/istio-remote"
alias i="istioctl --kubeconfig ~/shop_config/kubeconfig/istio-remote"

# echo "clean"
# k delete ns istio-system >/dev/null 2>&1

echo "install istio"
i install -y --set profile=demo \
    --set meshConfig.enableEnvoyAccessLogService=true \
    --set meshConfig.defaultConfig.envoyAccessLogService.address=skywalking-oap.istio-system:11800
echo "istiod installed"