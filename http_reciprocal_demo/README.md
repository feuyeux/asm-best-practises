## Http POD|VM Traffic Shifting

### 1 init vm ssh
```sh
nano reciprocal.config
sh vm/init.ssh.sh
sh vm/init.docker.sh
```

### 2 deploy to asm
```sh
sh asm/ack.deploy.sh

sh asm/asm.deploy.sh
sh asm/asm_traffic_shift.sh
sh asm/dns.fake.sh
sh asm/tracing.sh
```

#### edit workload
```yaml
spec:
  address: 192.168.0.170
  labels:
    app: hello-workload
    version: v1
```

```yaml
spec:
  address: 192.168.0.170
  labels:
    app: hello-workload
    version: v1
  serviceAccount: http-sa

```
### 3 start app on vm
```sh
docker pull registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.0
docker pull registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.0
docker pull registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.0

sh vm/ssh1.sh

curl hello3-svc.http-reciprocal-hello.svc.cluster.local:8001/hello/cool

docker run \
--rm \
--network host \
--name http_v1 \
-e HTTP_HELLO_BACKEND=hello3-svc.http-reciprocal-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.0
```

```sh
sh vm/ssh2.sh

docker run \
--rm \
--network host \
--name http_v2 \
-e HTTP_HELLO_BACKEND=hello3-svc.http-reciprocal-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.0
```

```sh
sh vm/ssh3.sh

docker run \
--rm \
--network host \
--name http_v3 \
-e HTTP_HELLO_BACKEND=hello3-svc.http-reciprocal-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.0
```

### 4 test 
#### access
```sh
sh asm/test_mesh.sh
```
#### traffic shift
```sh
sh test_traffic_shift.sh
```