alias k="kubectl --kubeconfig ${HOME}/shop/KUBE"
hello1_v2_pod=$(k get pod -l app=hello1-deploy-v2 -n http-hello -o jsonpath={.items..metadata.name})
k -n http-hello logs -f $hello1_v2_pod -c istio-proxy