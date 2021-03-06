## Http WorkloadEntry Traffic Shifting
<img src="../img/workload-traffic-demo.png" height="300" />

### 1 init vm ssh
```sh
nano hybrid.config
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
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.0
```

```sh
sh vm/ssh2.sh

docker run \
--rm \
--network host \
--name http_v2 \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.0
```

```sh
sh vm/ssh3.sh

docker run \
--rm \
--network host \
--name http_v3 \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.0
```

#### test vm app
```sh
sh vm/test_http.sh
```

### 3 deploy to asm
```sh
sh asm/ack.deploy.sh
sh asm/asm.deploy.sh
```
#### test mesh
```sh
sh asm/test_mesh.sh
```

### 4 add traffic shift on asm
```sh
sh asm/asm_traffic_shift.sh
```

#### edit workload
```yaml
spec:
  address: 192.168.0.170
  labels:
    app: hello-workload
    version: v1
```

#### test traffic shift
```sh
sh test_traffic_shift.sh
```