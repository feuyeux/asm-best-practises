## Http Traffic Shifting

### 1 build docker
```sh
sh docker/docker.build.sh
```

#### test docker
```sh
sh docker/test/start.http_springboot_v3.sh
```

```sh
sh docker/test/start.http_springboot_v3_proxy.sh
```

```sh
sh docker/test/test.sh 
```

### 2 push docker
https://cr.console.aliyun.com/cn-beijing/instances/credentials
```sh
CR_USER=$(head $HOME/shop_config/cr)
docker login --username=$CR_USER registry.cn-beijing.aliyuncs.com
```

```sh
docker/docker.push.sh
```

### 3 deploy to asm
```sh
nano asm/asm.config
sh asm/ack.deploy.sh
sh asm/test_kube.sh
```

#### test mesh
```sh
sh asm/asm.deploy.sh
sh asm/test_mesh2.sh
sh asm/test_mesh.sh
```

### all in one
```sh
docker/docker.build.sh
docker/docker.push.sh
sh asm/ack.deploy.sh
sh asm/asm.deploy.sh
sh asm/test_kube.sh
sh asm/test_mesh.sh
```

```sh
sh asm/ack.deploy.sh && sleep 10s && sh asm/asm.deploy.sh && sleep 10s && sh asm/test_mesh.sh 
```