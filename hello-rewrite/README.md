## Hello Rewrite

#### build docker image
```bash
sh build.sh
```

#### local test image
```bash
docker run -p 12321:12321 feuyeux/http-hello:0.0.1
```

```bash
curl http://localhost:12321/hello/123
curl http://localhost:12321/bye/123
```

#### deploy & test (on ack & asm)
```bash
sh deploy.sh
```