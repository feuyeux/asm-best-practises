## gRPC Traffic Shifting

### 1 build docker
```sh
$ sh docker/docker.build.sh
```

#### test docker
```sh
docker/test/start.grpc_springboot_v1.sh
docker/test/start.grpc_springboot_v2.sh
docker/test/start.grpc.consumer.sh
docker/test/grpc.consumer.test.sh
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
```

```sh
sh asm/ack.deploy.sh
sh asm/test_kube.sh
```

```sh
sh asm/asm.deploy.sh

docker/test/start.grpc.consumer.sh
sh asm/test_mesh.sh
```

### appendix
```sh
$ brew install grpcurl
```

- https://github.com/LogNet/grpc-spring-boot-starter
- https://github.com/fullstorydev/grpcurl