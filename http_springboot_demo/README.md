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
https://cr.console.aliyun.com/cn-beijing/instances/credentials
```sh
<<<<<<< HEAD
docker login --username= registry.cn-beijing.aliyuncs.com
=======
CR_USER=
docker login --username=$CR_USER registry.cn-beijing.aliyuncs.com
>>>>>>> 9cc6f6c8a3798b3ed86027e67f5ade05b6a3ada3
docker/docker.push.sh
```

### 3 deploy to asm
```sh
$ nano asm/asm.config
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