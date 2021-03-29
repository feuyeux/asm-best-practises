#!/bin/bash
cd "$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/" || exit

env GOOS=linux GOARCH=amd64 go build -o bin/http-hello main.go
docker build -t feuyeux/http-hello:0.0.1 .
docker push feuyeux/http-hello:0.0.1