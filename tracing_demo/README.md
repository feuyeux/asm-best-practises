## tracing

### 1 zipkin
#### setup
```sh
sh trace/zipkin.setup.sh
```
#### dns
```sh
sh trace/zipkin.dns.sh
```

#### access
```sh
sh trace/zipkin.url.sh
```
### 1 xtrace
#### setup to ack
```sh
sh trace/xtrace.setup.sh
```
#### dns to vm
```sh
sh trace/xtrace.dns.sh
```
#### access
https://tracing-analysis.console.aliyun.com

### 2 istio-agent
```sh
nano /var/lib/istio/envoy/sidecar.env
```

```.env
ISTIO_AGENT_FLAGS="--zipkinAddress zipkin.istio-system:9411 --serviceCluster vm1-hello2-en"
```

```sh
systemctl restart istio
```
### 3 deploy to asm
```sh
sh asm/ack.deploy.sh
sh asm/asm.deploy.sh
sh asm/asm_traffic_shift.sh
sh asm/dns.fake.sh
```

#### edit workload
```yaml
spec:
  address: 192.168.0.170
  labels:
    app: hello-workload
    version: v1
```

### 4 start app on vm
```sh
sh vm/ssh1.sh

docker pull registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.1
docker run \
--rm \
--network host \
--name http_v1 \
-e HTTP_HELLO_BACKEND=hello3-svc.trace-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.1
```

```sh
sh vm/ssh2.sh

docker pull registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.1
docker run \
--rm \
--network host \
--name http_v2 \
-e HTTP_HELLO_BACKEND=hello3-svc.trace-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.1
```

```sh
sh vm/ssh3.sh

docker pull registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.1
docker run \
--rm \
--network host \
--name http_v3 \
-e HTTP_HELLO_BACKEND=hello3-svc.trace-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.1
```

#### test vm app
```sh
sh vm/test_http.sh
```

### 5 test 
#### access
```sh
sh asm/test_mesh.sh
```
#### traffic shift
```sh
sh test_traffic_shift.sh
```