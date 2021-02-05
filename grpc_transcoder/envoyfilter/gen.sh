#!/usr/bin/env bash
SCRIPT_PATH="$(
        cd "$(dirname "$0")" >/dev/null 2>&1 || exit
        pwd -P
)"
cd "$SCRIPT_PATH" || exit

# git clone https://github.com/AliyunContainerService/hello-servicemesh-grpc
HELLO_GRPC=$HOME/cooding/alibaba/hello-servicemesh-grpc
proto_path="$HELLO_GRPC/proto"
# https://github.com/grpc-ecosystem/grpc-gateway/tree/master/third_party/
proto_dep_path=$HOME/cooding/github/grpc-gateway/third_party/googleapis
# git clone https://github.com/AliyunContainerService/grpc-transcoder

cd $HOME/cooding/alibaba/grpc-transcoder
echo "protoc \n--proto_path=${proto_path} \n--proto_path=${proto_dep_path}
--include_imports \n--include_source_info \n--descriptor_set_out=landing.pb \n${proto_path}/landing2.proto"
protoc \
    --proto_path=${proto_path} \
    --proto_path=${proto_dep_path} \
    --include_imports \
    --include_source_info \
    --descriptor_set_out=landing.pb \
    "${proto_path}"/landing2.proto
echo "Use Protobuf Compiler to generate Protobuf Descriptor done."
make build
$HOME/cooding/alibaba/grpc-transcoder/grpc-transcoder \
--version 1.7 \
--service_port 9996 \
--service_name grpc-server-svc \
--proto_pkg org.feuyeux.grpc \
--proto_svc LandingService \
--header x=a,y=b \
--descriptor landing.pb