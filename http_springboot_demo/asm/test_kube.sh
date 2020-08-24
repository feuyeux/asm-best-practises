#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source asm.config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get pod -l app=hello1-deploy -n http-hello -o jsonpath={.items..metadata.name})
hello3_pod=$(k get pod -l app=hello3-deploy -n http-hello -o jsonpath={.items..metadata.name})
v1_pod=$(k get pod -l app=hello2-deploy -n http-hello -o jsonpath='{.items[0].metadata.name}')
v2_pod=$(k get pod -l app=hello2-deploy -n http-hello -o jsonpath='{.items[1].metadata.name}')
v3_pod=$(k get pod -l app=hello2-deploy -n http-hello -o jsonpath='{.items[2].metadata.name}')

if [ -z "$proxy_pod" ]; then
  echo "Check from $hello1_pod:"
  k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s localhost:8001/hello/eric
  echo
  k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s http://hello3-svc:8001/hello/eric
  echo
  k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s http://hello2-svc:8001/hello/eric
  echo
  k exec "$hello1_pod" -c hello-v1-deploy -n http-hello -- curl -s http://hello1-svc:8001/hello/eric
  echo
else
  echo "Check from hello-proxy-deploy:"
  echo "proxy_pod=$proxy_pod"
  k exec "$proxy_pod" -c hello-proxy-deploy -n http-hello -- curl -s localhost:7001/hello/eric
  echo
  k exec "$proxy_pod" -c hello-proxy-deploy -n http-hello -- curl -s http://http-hello-svc:8001/hello/eric
  echo
fi

echo "Check from hello2-deploy v3:"
k exec "$v3_pod" -c hello-v3-deploy -n http-hello -- curl -s localhost:8001/hello/eric
