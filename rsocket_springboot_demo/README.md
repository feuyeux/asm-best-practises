## RSocket Traffic Shifting

### 1 build docker
```sh
sh docker/docker.build.sh
```

#### test tcp docker
one terminal one cmd:
```sh
sh docker/test/start.rsocket_springboot_v2.sh tcp
sh docker/test/start.rsocket_springboot_v1.sh tcp
sh docker/test/start.rsocket.requester.sh tcp 6666 8001
sh docker/test/start.rsocket.requester.sh tcp 6667 9001
sh docker/test/rsocket.requester.test.sh
```

#### test ws docker
one terminal one cmd:
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
```
```sh
sh docker/docker.push.sh
```

### 3 deploy to 
#### websockets
```sh
nano asm/asm.config
```

```sh
sh asm/websockets/ack.deploy.sh
sh asm/websockets/asm.deploy.sh

sh asm/websockets/start.rsocket.requester.sh
sh asm/websockets/test_mesh.sh
```

#### tcp 
```sh
sh asm/ack.deploy.sh
sh asm/test_kube.sh
```

```sh
sh asm/asm.deploy.sh

docker/test/start.grpc.consumer.sh
sh asm/test_mesh.sh
```



#### test mesh
```sh
sh asm/test_kube.sh

docker/test/start.grpc.consumer.sh
sh asm/test_mesh.sh
```

