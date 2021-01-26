#!/usr/bin/env sh
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit

export ISTIO_HOME=/Users/han/shop/istio-1.8.1
export PATH=$PATH:$ISTIO_HOME/bin
alias k="kubectl --kubeconfig istio-kubeconfig"
alias i="istioctl --kubeconfig istio-kubeconfig"

echo "#### I Prerequisites ####"
echo "1 Install Istio with telemetry support and Prometheus:"
i manifest install --set profile=default
k apply -f $ISTIO_HOME/samples/addons/prometheus.yaml

echo "2 Install Flagger in the istio-system namespace[kustomize]:"
k apply -k github.com/fluxcd/flagger//kustomize/istio

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

echo
echo "#### II Bootstrap ####"

echo "1 Create a test namespace with Istio sidecar injection enabled:"
k create ns test
k label namespace test istio-injection=enabled

echo "2 Create a deployment and a horizontal pod autoscaler:"
k apply -k https://github.com/fluxcd/flagger//kustomize/podinfo?ref=main

echo "3 Deploy the load testing service to generate traffic during the canary analysis:"
k apply -k https://github.com/fluxcd/flagger//kustomize/tester?ref=main

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
    - *
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

echo
echo "#### III Automated canary promotion ####"

echo "1 Trigger a canary deployment by updating the container image:"
k -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.1

echo "2 Flagger detects that the deployment revision changed and starts a new rollout:"

while true; do k -n test describe canary/podinfo; sleep 10s;done

# Events:
#   Type    Reason  Age   From     Message
#   ----    ------  ----  ----     -------
#   Normal  Synced  6m8s  flagger  New revision detected! Scaling up podinfo.test
#   Normal  Synced  5m8s  flagger  New revision detected! Restarting analysis for podinfo.test
#   Normal  Synced  4m8s  flagger  Starting canary analysis for podinfo.test
#   Normal  Synced  4m8s  flagger  Pre-rollout check acceptance-test passed
#   Normal  Synced  4m7s  flagger  Advance podinfo.test canary weight 10
#   Normal  Synced  3m8s  flagger  Advance podinfo.test canary weight 20
#   Normal  Synced  2m8s  flagger  Advance podinfo.test canary weight 30
#   Normal  Synced  68s   flagger  Advance podinfo.test canary weight 40
#   Normal  Synced  8s    flagger  Advance podinfo.test canary weight 50

# Events:
#   Type    Reason  Age               From     Message
#   ----    ------  ----              ----     -------
#   Normal  Synced  8m9s              flagger  New revision detected! Scaling up podinfo.test
#   Normal  Synced  7m9s              flagger  New revision detected! Restarting analysis for podinfo.test
#   Normal  Synced  6m9s              flagger  Starting canary analysis for podinfo.test
#   Normal  Synced  6m9s              flagger  Pre-rollout check acceptance-test passed
#   Normal  Synced  6m8s              flagger  Advance podinfo.test canary weight 10
#   Normal  Synced  5m9s              flagger  Advance podinfo.test canary weight 20
#   Normal  Synced  4m9s              flagger  Advance podinfo.test canary weight 30
#   Normal  Synced  3m9s              flagger  Advance podinfo.test canary weight 40
#   Normal  Synced  2m9s              flagger  Advance podinfo.test canary weight 50
#   Normal  Synced  9s (x2 over 69s)  flagger  (combined from similar events): Routing all traffic to primary

watch kubectl --kubeconfig istio-kubeconfig get canaries --all-namespaces

# Every 2.0s: kubectl --kubeconfig i...  East6C16G: Tue Jan 26 13:40:38 2021

# NAMESPACE   NAME      STATUS        WEIGHT   LASTTRANSITIONTIME
# test        podinfo   Progressing   50       2021-01-26T05:40:16Z


# Every 2.0s: kubectl --kubeconfig i...  East6C16G: Tue Jan 26 13:42:21 2021

# NAMESPACE   NAME      STATUS       WEIGHT   LASTTRANSITIONTIME
# test        podinfo   Finalising   0        2021-01-26T05:42:16Z