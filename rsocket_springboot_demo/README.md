## RSocket Traffic Shifting

### 1 build docker
```sh
sh docker/docker.build.sh
```

#### test docker
one terminal one cmd:
```sh
sh docker/test/start.rsocket_springboot_v2.sh tcp
sh docker/test/start.rsocket_springboot_v1.sh tcp
sh docker/test/start.rsocket.requester.sh tcp 6666 8001
sh docker/test/start.rsocket.requester.sh tcp 6667 9001
sh docker/test/rsocket.requester.test.sh
```

```sh
sh docker/test/start.rsocket_springboot_v3.sh ws
sh docker/test/start.rsocket_springboot_v1.sh ws
sh docker/test/start.rsocket.requester.sh ws 6666 8001
sh docker/test/start.rsocket.requester.sh ws 6667 9001
sh docker/test/rsocket.requester.test.sh
```

### 2 push docker
https://cr.console.aliyun.com/cn-beijing/instances/credentials
```sh
CR_USER=$(head $HOME/shop_config/cr)
docker login --username=$CR_USER registry.cn-beijing.aliyuncs.com
docker/docker.push.sh
```

### 3 deploy to asm
```sh
nano asm/asm.config

sh asm/ack.deploy.sh
sh asm/asm.deploy.sh
```

#### test mesh
```sh
sh asm/test_kube.sh

docker/test/start.grpc.consumer.sh
sh asm/test_mesh.sh
```

