## Http Hybrid Traffic Shifting

### 1 init vm ssh
```sh
nano hybrid.config
sh vm/init.ssh.sh
sh vm/init.docker.sh
```

### 2 deploy to asm
```sh
sh asm/ack.deploy.sh
sh asm/asm.deploy.sh
```

#### dns for mesh
```sh
sh vm/dns.fake.sh
```

### 3 start app on vm
```sh
sh vm/ssh2.sh
#systemctl start docker
docker run \
--rm \
--network host \
--name http_v2 \
-e HTTP_HELLO_BACKEND=hello3-svc.hybrid-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.0
```

```sh
sh vm/ssh3.sh

docker run \
--rm \
--network host \
--name http_v3 \
-e HTTP_HELLO_BACKEND=hello3-svc.hybrid-hello.svc.cluster.local \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v3:1.0.0
```

### 4 test mesh
```sh
sh asm/test_kube.sh
```

### 5 add traffic shift on asm
```sh
sh asm/asm_traffic_shift.sh
```

#### edit workload
```yaml
spec:
  address: 192.168.0.170
  labels:
    app: hello-workload
    version: v2
```

#### test traffic shift
```sh
sh asm/test_mesh.sh
```

### 6 end-2-end test traffic shift
```sh
sh asm/asm_z.sh
```

```sh
sh asm/test_z.sh
```