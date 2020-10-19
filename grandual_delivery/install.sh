source config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias h="helm --kubeconfig $USER_CONFIG"

#k -n istio-system create secret generic istio-kubeconfig --from-file $MESH_CONFIG

h repo add flagger https://flagger.app
h repo update
k apply -f $FLAAGER_SRC/artifacts/flagger/crd.yaml

h upgrade --dry-run --debug \
-i flagger flagger/flagger \
--namespace=istio-system \
--set crd.create=false \
--set meshProvider=istio \
--set metricsServer=http://ack-prometheus-operator-prometheus:9090 \
--set istio.kubeconfig.secretName=istio-kubeconfig \
--set istio.kubeconfig.key=kubeconfig > flagger_helm_installation.yaml

# k delete psp ack-prometheus-operator-grafana
# k delete psp ack-prometheus-operator-grafana-test
# k delete psp ack-prometheus-operator-kube-state-metrics
# k delete psp ack-prometheus-operator-prometheus-node-exporter
# k delete psp ack-prometheus-operator-alertmanager
# k delete psp ack-prometheus-operator-operator
# k delete psp ack-prometheus-operator-prometheus
# k delete psp ack-prometheus-operator-grafana-clusterrole

# k delete ClusterRole ack-prometheus-operator-alertmanager 
# k delete ClusterRole ack-prometheus-operator-grafana-clusterrole
# k delete ClusterRole ack-prometheus-operator-kube-state-metrics
# k delete ClusterRole ack-prometheus-operator-operator
# k delete ClusterRole ack-prometheus-operator-operator-psp
# k delete ClusterRole ack-prometheus-operator-prometheus
# k delete ClusterRole ack-prometheus-operator-prometheus-psp
# k delete ClusterRole ack:podsecuritypolicy:privileged
# k delete ClusterRole psp-ack-prometheus-operator-kube-state-metrics
# k delete ClusterRole psp-ack-prometheus-operator-prometheus-node-exporter

# k delete ClusterRoleBinding ack-prometheus-operator-alertmanager                   
# k delete ClusterRoleBinding ack-prometheus-operator-grafana-clusterrolebinding     
# k delete ClusterRoleBinding ack-prometheus-operator-kube-state-metrics             
# k delete ClusterRoleBinding ack-prometheus-operator-operator                       
# k delete ClusterRoleBinding ack-prometheus-operator-operator-psp                   
# k delete ClusterRoleBinding ack-prometheus-operator-prometheus                     
# k delete ClusterRoleBinding ack-prometheus-operator-prometheus-psp 
# k delete ClusterRoleBinding psp-ack-prometheus-operator-kube-state-metrics
# k delete ClusterRoleBinding psp-ack-prometheus-operator-prometheus-node-exporter

# k delete Role -n kube-system ack-prometheus-operator-prometheus
# k delete RoleBinding -n kube-system ack-prometheus-operator-prometheus
# k delete Service -n kube-system ack-prometheus-operator-coredns
# k delete Service -n kube-system ack-prometheus-operator-kube-controller-manager
# k delete Service -n kube-system ack-prometheus-operator-kubelet  
# k delete Service -n kube-system ack-prometheus-operator-kube-scheduler