## Http Traffic Shifting

### 1 build docker
```sh
$ sh docker/docker.build.sh
```

#### test docker
```sh
docker/test/start.http_springboot_v3.sh
```

```sh
docker/test/start.http_springboot_v3_proxy.sh
#docker/test/start.http_springboot_proxy.sh 
```

```sh
docker/test/test.sh 
```

### 2 push docker
```sh
docker login --username= registry.cn-beijing.aliyuncs.com
docker/docker.push.sh
```

### 3 deploy to asm
```sh
$ sh asm/ack.deploy.sh
$ sh asm/asm.deploy.sh
```

#### test mesh
```sh
$ sh asm/test_kube.sh
$ sh asm/test_mesh.sh
```

### all in one
```sh
docker/docker.build.sh && docker/docker.push.sh && asm/ack.deploy.sh
asm/asm.deploy.sh && sleep 20s && test/asm/test_mesh.sh
```

```sh
asm/asm.deploy.sh && sleep 20s && test/asm/test_mesh.sh
```