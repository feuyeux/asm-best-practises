## progressive_delivery

### 1 Mixerless Telemetry
[demo_mixerless.sh](demo_mixerless.sh)
#### 部署
- [x] envoyfilter
- [x] prometheus
- [x] podinfo

#### 验证
- [x] istio_requests_total
- [x] istio_request_duration

### 2 HPA
[demo_hpa.sh](demo_hpa.sh)
#### 部署
- [x] kube-metrics-adapter
- [x] flagger-loadtester
- [x] `$FLAAGER_SRC/kustomize/podinfo`
- [x] `$FLAAGER_SRC/kustomize/tester`
#### 验证
- [x] podinfo scaling

### 3 Canary
[demo_canary.sh](demo_canary.sh)
#### 部署
- [x] flagger
- [x] `$FLAAGER_SRC/kustomize/podinfo`
- [x] `$FLAAGER_SRC/kustomize/tester`
#### 验证
- [ ] podinfo-canary

### reference
- https://docs.flagger.app/usage/metrics
- https://flagger.app/intro/faq.html#metrics