#!/usr/bin/env sh

alias k="kubectl --kubeconfig ~/shop/bj_config"
k version
proxy_pod=$(k get pod -l app=http-hello-proxy-deploy -o jsonpath={.items..metadata.name})
k exec $proxy_pod -c http-hello-proxy-deploy -- curl -s http://http-hello-svc:8001/hello/feuyeux
k exec $proxy_pod -c http-hello-proxy-deploy -- curl -s localhost:7001/hello/feuyeux

v3_pod=$(k get pod -l app=http-hello-deploy -o jsonpath='{.items[2].metadata.name}')
k exec $v3_pod -c http-hello-deploy -- curl -s localhost:8001/hello/feuyeux