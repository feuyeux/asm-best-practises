#!/usr/bin/env sh
# https://docs.flagger.app/tutorials/istio-progressive-delivery

SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
export ISTIO_HOME=/Users/han/shop/istio-1.7.5
export PATH=$PATH:$ISTIO_HOME/bin
alias k="kubectl --kubeconfig $HOME/shop_config/ack_istio"
alias i="istioctl --kubeconfig $HOME/shop_config/ack_istio"

echo "#### I Prerequisites ####"
echo "1 Install Istio with telemetry support and Prometheus:"
k delete ns test
k delete ns istio-system
i manifest install --set profile=default -y
k apply -f $ISTIO_HOME/samples/addons/prometheus.yaml
k get pod,svc -n istio-system
# NAME                                        READY   STATUS    RESTARTS   AGE
# pod/istio-ingressgateway-7bb888bf54-966df   1/1     Running   0          7m41s
# pod/istiod-74676d784-wlsw6                  1/1     Running   0          7m47s
# pod/prometheus-9d5676d95-nh5vx              2/2     Running   0          6m54s

# NAME                           TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                                                      AGE
# service/istio-ingressgateway   LoadBalancer   172.21.8.101   39.105.187.16   15021:31055/TCP,80:32247/TCP,443:30164/TCP,15443:31932/TCP   7m41s
# service/istiod                 ClusterIP      172.21.12.20   <none>          15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                7m47s
# service/prometheus             ClusterIP      172.21.5.189   <none>          9090/TCP                                                     6m54s

k get cm prometheus -n istio-system -o jsonpath={.data.prometheus\\.yml} | grep job_name                                                                                                                        130 ↵
# - job_name: prometheus
#   job_name: kubernetes-apiservers
#   job_name: kubernetes-nodes
#   job_name: kubernetes-nodes-cadvisor
# - job_name: kubernetes-service-endpoints
# - job_name: kubernetes-service-endpoints-slow
#   job_name: prometheus-pushgateway
# - job_name: kubernetes-services
# - job_name: kubernetes-pods
# - job_name: kubernetes-pods-slow

echo "2 Install Flagger in the istio-system namespace[kustomize]:"
k apply -k github.com/fluxcd/flagger//kustomize/istio
k get pod,svc -n istio-system
# NAME                                        READY   STATUS    RESTARTS   AGE
# pod/flagger-759dfbb57f-dcdjr                1/1     Running   0          18s
# pod/istio-ingressgateway-7bb888bf54-966df   1/1     Running   0          8m30s
# pod/istiod-74676d784-wlsw6                  1/1     Running   0          8m36s
# pod/prometheus-9d5676d95-nh5vx              2/2     Running   0          7m43s

# NAME                           TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                                                      AGE
# service/istio-ingressgateway   LoadBalancer   172.21.8.101   39.105.187.16   15021:31055/TCP,80:32247/TCP,443:30164/TCP,15443:31932/TCP   8m30s
# service/istiod                 ClusterIP      172.21.12.20   <none>          15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                8m36s

echo "3 Create an ingress gateway to expose the demo app outside of the mesh:"
cat <<EOF | k apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: public-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - "*"
EOF

echo "......"
sleep 10s
echo "#### II Bootstrap ####"

echo "1 Create a test namespace with Istio sidecar injection enabled:"
k create ns test
k label namespace test istio-injection=enabled

echo "2 Create a deployment and a horizontal pod autoscaler:"
k apply -k https://github.com/fluxcd/flagger//kustomize/podinfo?ref=main
k get pod,svc -n test
# NAME                           READY   STATUS    RESTARTS   AGE
# pod/podinfo-689f645b78-swfrt   2/2     Running   0          3m25s
# pod/podinfo-689f645b78-vjvkw   2/2     Running   0          3m40s

echo "3 Deploy the load testing service to generate traffic during the canary analysis:"
k apply -k https://github.com/fluxcd/flagger//kustomize/tester?ref=main
k get pod,svc -n test
# NAME                                      READY   STATUS    RESTARTS   AGE
# pod/flagger-loadtester-76798b5f4c-7nrsb   2/2     Running   0          100s
# pod/podinfo-689f645b78-swfrt              2/2     Running   0          5m45s
# pod/podinfo-689f645b78-vjvkw              2/2     Running   0          6m

# NAME                         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
# service/flagger-loadtester   ClusterIP   172.21.6.200   <none>        80/TCP    100s
echo "......"
sleep 20s
echo "4 Create a canary custom resource:"
cat <<EOF | k apply -f -
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: podinfo
  namespace: test
spec:
  # deployment reference
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: podinfo
  # the maximum time in seconds for the canary deployment
  # to make progress before it is rollback (default 600s)
  progressDeadlineSeconds: 60
  # HPA reference (optional)
  autoscalerRef:
    apiVersion: autoscaling/v2beta2
    kind: HorizontalPodAutoscaler
    name: podinfo
  service:
    # service port number
    port: 9898
    # container port number or name (optional)
    targetPort: 9898
    # Istio gateways (optional)
    gateways:
    - public-gateway.istio-system.svc.cluster.local
    # Istio virtual service host names (optional)
    hosts:
    - "*"
    # Istio traffic policy (optional)
    trafficPolicy:
      tls:
        # use ISTIO_MUTUAL when mTLS is enabled
        mode: DISABLE
    # Istio retry policy (optional)
    retries:
      attempts: 3
      perTryTimeout: 1s
      retryOn: "gateway-error,connect-failure,refused-stream"
  analysis:
    # schedule interval (default 60s)
    interval: 1m
    # max number of failed metric checks before rollback
    threshold: 5
    # max traffic percentage routed to canary
    # percentage (0-100)
    maxWeight: 50
    # canary increment step
    # percentage (0-100)
    stepWeight: 10
    metrics:
    - name: request-success-rate
      # minimum req success rate (non 5xx responses)
      # percentage (0-100)
      thresholdRange:
        min: 99
      interval: 1m
    - name: request-duration
      # maximum req duration P99
      # milliseconds
      thresholdRange:
        max: 500
      interval: 30s
    # testing (optional)
    webhooks:
      - name: acceptance-test
        type: pre-rollout
        url: http://flagger-loadtester.test/
        timeout: 30s
        metadata:
          type: bash
          cmd: "curl -sd 'test' http://podinfo-canary:9898/token | grep token"
      - name: load-test
        url: http://flagger-loadtester.test/
        timeout: 5s
        metadata:
          cmd: "hey -z 1m -q 10 -c 2 http://podinfo-canary.test:9898/"
EOF

k get pod,svc -n test
# NAME                                      READY   STATUS    RESTARTS   AGE
# pod/flagger-loadtester-76798b5f4c-7nrsb   2/2     Running   0          3m9s
# pod/podinfo-689f645b78-swfrt              2/2     Running   0          7m14s
# pod/podinfo-689f645b78-vjvkw              2/2     Running   0          7m29s
# pod/podinfo-primary-7b7dd49c6f-l72z5      2/2     Running   0          38s
# pod/podinfo-primary-7b7dd49c6f-m78sb      2/2     Running   0          38s

# NAME                         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
# service/flagger-loadtester   ClusterIP   172.21.6.200   <none>        80/TCP     3m9s
# service/podinfo-canary       ClusterIP   172.21.0.83    <none>        9898/TCP   38s
# service/podinfo-primary      ClusterIP   172.21.9.9     <none>        9898/TCP   38s

echo "......"
sleep 20s
echo "#### III Automated canary promotion ####"

echo "1 Trigger a canary deployment by updating the container image:"
k -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.1

echo "2 Flagger detects that the deployment revision changed and starts a new rollout:"

while true; do k -n test describe canary/podinfo; sleep 10s;done
# Events:
#   Type     Reason  Age                From     Message
#   ----     ------  ----               ----     -------
#   Warning  Synced  39m                flagger  podinfo-primary.test not ready: waiting for rollout to finish: observed deployment generation less then desired generation
#   Normal   Synced  38m (x2 over 39m)  flagger  all the metrics providers are available!
#   Normal   Synced  38m                flagger  Initialization done! podinfo.test
#   Normal   Synced  37m                flagger  New revision detected! Scaling up podinfo.test
#   Normal   Synced  36m                flagger  Starting canary analysis for podinfo.test
#   Normal   Synced  36m                flagger  Pre-rollout check acceptance-test passed
#   Normal   Synced  36m                flagger  Advance podinfo.test canary weight 10
#   Normal   Synced  35m                flagger  Advance podinfo.test canary weight 20
#   Normal   Synced  34m                flagger  Advance podinfo.test canary weight 30
#   Normal   Synced  33m                flagger  Advance podinfo.test canary weight 40
#   Normal   Synced  29m (x4 over 32m)  flagger  (combined from similar events): Promotion completed! Scaling down podinfo.test

watch kubectl --kubeconfig istio-kubeconfig get canaries --all-namespaces

# Every 2.0s: kubectl --kubeconfig i...  East6C16G: Tue Jan 26 13:40:38 2021

# NAMESPACE   NAME      STATUS        WEIGHT   LASTTRANSITIONTIME
# test        podinfo   Progressing   50       2021-01-26T05:40:16Z


# Every 2.0s: kubectl --kubeconfig i...  East6C16G: Tue Jan 26 13:42:21 2021

# NAMESPACE   NAME      STATUS       WEIGHT   LASTTRANSITIONTIME
# test        podinfo   Finalising   0        2021-01-26T05:42:16Z