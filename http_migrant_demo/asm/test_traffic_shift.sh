#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../hybrid.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n migrant-hello -o jsonpath={.items..metadata.name})
echo "Test route(hello2-svc) in a loop"
# warm-up
for i in {1..10}; do
  k exec "$hello1_pod" -c hello-v1-deploy -n migrant-hello -- curl -s hello1-svc.migrant-hello.svc.cluster.local:8004/hello/eric
  echo
  k exec "$hello1_pod" -c hello-v1-deploy -n migrant-hello -- curl -s hello1-svc.migrant-hello.svc.cluster.local:8004/bye
  echo
done
echo >test_traffic_shift_result
for i in {1..20}; do
  resp=$(k exec "$hello1_pod" -c hello-v1-deploy -n migrant-hello -- curl -s hello1-svc.migrant-hello.svc.cluster.local:8004/hello/eric)
  echo "$resp" >>test_traffic_shift_result
done

echo "expected 30%(Hello eric)-60%(Bonjour eric)-10%(Hola eric):"
sort test_traffic_shift_result | uniq -c | sort -nrk1

echo >test_traffic_shift_result
for i in {1..20}; do
  resp=$(k exec "$hello1_pod" -c hello-v1-deploy -n migrant-hello -- curl -s hello1-svc.migrant-hello.svc.cluster.local:8004/bye)
  echo "$resp" >>test_traffic_shift_result
done

echo "expected 90%(Bye bye)-5%(Au revoir)-5%(Adióbais):"
sort test_traffic_shift_result | uniq -c | sort -nrk1

rm -rf test_traffic_shift_result
