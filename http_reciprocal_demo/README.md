## Http POD|VM Traffic Shifting

### 1 init vm ssh
```sh
nano reciprocal.config
sh vm/init.ssh.sh
sh vm/init.docker.sh
```

### 2 start app on vm
```sh
sh vm/ssh1.sh

docker run \
--rm \
--network host \
--name http_v1 \
-e HTTP_HELLO_BACKEND=hello3-svc.http-reciprocal-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.1
```

```sh
sh vm/ssh2.sh

docker run \
--rm \
--network host \
--name http_v2 \
-e HTTP_HELLO_BACKEND=hello3-svc.http-reciprocal-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.1
```

```sh
sh vm/ssh3.sh

docker run \
--rm \
--network host \
--name http_v3 \
-e HTTP_HELLO_BACKEND=hello3-svc.http-reciprocal-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.1
```

#### test vm app
```sh
sh vm/test_http.sh
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

### 4 test 
#### access
```sh
sh asm/test_mesh.sh
```
#### traffic shift
```sh
sh test_traffic_shift.sh
```