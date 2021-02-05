# grpc-transcoder

1 generate pb and envoyfilter
```sh
sh envoyfilter/gen.sh
```

2 verify envoy config
```sh
sh envoyfilter/verify.sh
```

3 deploy grpc service
```sh
sh kube/deploy.sh
```

4 test http request over grpc-transcoder
```sh
sh kube/test-transcoder.sh
```

### reference
- https://github.com/tetratelabs/istio-tools.git 
- https://github.com/feuyeux/transcoding-grpc-to-http-json.git
- https://github.com/grpc-ecosystem/grpc-gateway/tree/master/third_party/