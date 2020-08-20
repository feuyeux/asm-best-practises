## circuit breaking

### http circuit breaking

```sh
cd http
# 搭建环境
sh circuit_breaking.sh
# 熔断验证
sh http_test.sh
```

### grpc circuit breaking

```sh
cd grpc
# 搭建环境
sh circuit_breaking.sh
# 熔断验证
sh grpc_test.sh
```

# reference
- https://github.com/fortio/fortio
- https://ghz.sh

```sh
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build .
tar zcvf ghz.tar.gz ghz
```