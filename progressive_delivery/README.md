## progressive_delivery

### 1 `demo_mixerless.sh`
#### 部署
- [x] envoyfilter
- [x] prometheus
- [x] grafana
- [x] podinfo

#### 验证
- [x] istio_requests_total
- [x] istio_request_duration

### 2 `demo_hpa.sh`
#### 部署
- [x] kube-metrics-adapter
- [x] flagger-loadtester
- [x] `$FLAAGER_SRC/kustomize/podinfo`
- [x] `$FLAAGER_SRC/kustomize/tester`
#### 验证
- [x] podinfo scaling

### 3 `demo_canary.sh`
#### 部署
- [x] flagger
- [x] `$FLAAGER_SRC/kustomize/podinfo`
- [x] `$FLAAGER_SRC/kustomize/tester`
#### 验证
- [ ] podinfo-canary

#### issue...
![](progressive_delivery/request-success-rate.png)

### reference
https://docs.flagger.app/usage/metrics
https://flagger.app/intro/faq.html#metrics
