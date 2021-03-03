#!/usr/bin/env bash
SCRIPT_PATH="$(
        cd "$(dirname "$0")" >/dev/null 2>&1 || exit
        pwd -P
)"
cd "$SCRIPT_PATH" || exit
set -e
. ../kube/config.env

proto_path="$HELLO_GRPC_HOME/proto"
proto_dep_path=$GOOGLEAPI_HOME

echo "protoc \n--proto_path=${proto_path} \n--proto_path=${proto_dep_path}
--include_imports \n--include_source_info \n--descriptor_set_out=landing.pb \n${proto_path}/landing2.proto"
cd $GRPC_TRANSCODER_HOME
protoc \
    --proto_path=${proto_path} \
    --proto_path=${proto_dep_path} \
    --include_imports \
    --include_source_info \
    --descriptor_set_out=landing.pb \
    "${proto_path}"/landing2.proto

echo "Use Protobuf Compiler to generate Protobuf Descriptor done."
make build
$GRPC_TRANSCODER_HOME/grpc-transcoder \
--version 1.8 \
--service_port 9996 \
--service_name grpc-server-svc \
--proto_pkg org.feuyeux.grpc \
--proto_svc LandingService \
--header x=a,y=b \
--descriptor landing.pb