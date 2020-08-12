
### setup mesh
```sh
sh hello-pod-vm.sh
```

### setup vm
```sh
sh ssh1.sh

docker run \
--rm \
--network host \
--name http_v1 \
registry.cn-beijing.aliyuncs.com/asm_repo/http_springboot_v1:1.0.1
```

### verify
```sh
sh test.sh
```

- https://istio.io/latest/blog/2020/workload-entry/
- https://istio.io/latest/docs/reference/config/networking/service-entry/