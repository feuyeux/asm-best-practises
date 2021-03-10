#!/usr/bin/env sh
alias i1="istioctl --kubeconfig ~/shop_config/kubeconfig/istio-primary"
alias i2="istioctl --kubeconfig ~/shop_config/kubeconfig/istio-remote"
alias k1="kubectl --kubeconfig ~/shop_config/kubeconfig/istio-primary"
alias k2="kubectl --kubeconfig ~/shop_config/kubeconfig/istio-remote"

cd ~/shop/istio-1.9.0
export PATH=$PATH:~/shop/istio-1.9.0/bin

echo "Install Primary-Remote"
echo "========\n"

echo "1 Configure cluster1 as a primary"
cat <<EOF >cluster1.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: cluster1
      network: network1
EOF
i1 install -f cluster1.yaml

echo "2 Install the east-west gateway in cluster1"
samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster cluster1 --network network1 |
    i1 install -y -f -

k1 get svc istio-eastwestgateway -n istio-system

echo "3 Expose the control plane in cluster1"
k1 apply -f samples/multicluster/expose-istiod.yaml

echo "4 Enable API Server Access to cluster2"
i1 x create-remote-secret \
    --name=cluster2 |
    k1 apply -f -

echo "5 Configure cluster2 as a remote"

export DISCOVERY_ADDRESS=$(k1 \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

cat <<EOF >cluster2.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: remote
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: cluster2
      network: network1
      remotePilotAddress: ${DISCOVERY_ADDRESS}
EOF

i2 -f cluster2.yaml

echo "\nVerify the installation"
echo "========\n"

echo "1 Deploy the HelloWorld Service"
k1 create namespace sample
k2 create namespace sample
k1 label namespace sample istio-injection=enabled
k2 label namespace sample istio-injection=enabled
k1 apply -f samples/helloworld/helloworld.yaml -l service=helloworld -n sample
k2 apply -f samples/helloworld/helloworld.yaml -l service=helloworld -n sample

echo "2 Deploy HelloWorld V1"
k1 apply -f samples/helloworld/helloworld.yaml -l version=v1 -n sample
k1 get pod -n sample -l app=helloworld

echo "3 Deploy HelloWorld V2"
k2 apply -f samples/helloworld/helloworld.yaml -l version=v2 -n sample
k2 get pod -n sample -l app=helloworld

echo "4 Deploy Sleep"
k1 apply -f samples/sleep/sleep.yaml -n sample
k2 apply -f samples/sleep/sleep.yaml -n sample

k1 get pod -n sample -l app=sleep
k2 get pod -n sample -l app=sleep

echo "5 Verifying Cross-Cluster Traffic"
k1 exec -n sample -c sleep "$(k1 get pod -n sample -l app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
k2 exec -n sample -c sleep "$(k2 get pod -n sample -l app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
