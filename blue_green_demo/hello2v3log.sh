alias k="kubectl --kubeconfig ${HOME}/shop/KUBE"
hello2_v3_pod=$(k get pod -l app=hello2-deploy-v3 -n http-hello -o jsonpath={.items..metadata.name})
k -n http-hello logs -f $hello2_v3_pod -c istio-proxy