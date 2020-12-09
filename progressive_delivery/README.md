## progressive_delivery

### 1 demo_mixerless.sh
envoyfilter
prometheus
grafana

podinfo

istio_requests_total
istio_request_duration

### 2 demo_hpa.sh
kube-metrics-adapter

flagger-loadtester

k apply -k $FLAAGER_SRC/kustomize/podinfo
k apply -k $FLAAGER_SRC/kustomize/tester

### 3 demo_canary.sh
flagger

k apply -k $FLAAGER_SRC/kustomize/podinfo
k apply -k $FLAAGER_SRC/kustomize/tester