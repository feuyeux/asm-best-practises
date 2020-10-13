## Http WorkloadEntry Blue Green

### 1 setup vm
vm1/vm2:
```sh
sh sh/ssh1.sh

docker run \
--rm \
--network host \
--name http_v1 \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.0
```
vm3/vm4:
```sh
sh sh/ssh3.sh

docker run \
--rm \
--network host \
--name http_v2 \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v2:1.0.0
```
test:
```sh
sh sh/vm-http-test.sh
```

### 2 setup mesh
```sh
sh sh/setup.sh
```

```yaml
spec:
  address: 192.168.0.171
  labels:
    app: http-workload
    version: v1
```
### 3 blue-green test
```sh
sh sh/vm-traffic-test.sh
```

### 4 land-evict test
```sh
sh sh/vm-group-test.sh
```