#!/usr/bin/env bash
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"
hello1_pod=$(k get pod -l app=hello1-deploy -n http-hello -o jsonpath={.items..metadata.name})

response=$(k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s hello1-svc.http-hello.svc.cluster.local:8001/hello/eric)
echo "$response"

echo
####
echo "Start test in loop:"
for ((i = 1; i <= 20; i++)); do
  response=$(k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s hello1-svc.http-hello.svc.cluster.local:8001/hello/eric)
  echo "$response"
done
for ((i = 1; i <= 100; i++)); do
  response=$(k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s hello1-svc.http-hello.svc.cluster.local:8001/hello/eric)
  echo "$response" >>result
  echo "" >>result
done
echo "expected 30-60-10:"
sort result | uniq -c | sort -nrk1
rm -f result
echo
for ((i = 1; i <= 20; i++)); do
  response=$(k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s hello1-svc.http-hello.svc.cluster.local:8001/bye)
  echo "$response"
done
for ((i = 1; i <= 100; i++)); do
  response=$(k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s hello1-svc.http-hello.svc.cluster.local:8001/bye)
  echo "$response" >>result
  echo "" >>result
done
echo "expected 90-5-5:"
sort result | uniq -c | sort -nrk1
echo
rm -f result
echo "Done."
