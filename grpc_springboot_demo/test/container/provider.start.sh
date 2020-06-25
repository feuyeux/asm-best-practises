#!/usr/bin/env bash
docker rm provider2
docker run --name provider2 -p 6565:6565 feuyeux/grpc_provider_v2:1.0.0

docker exec -it provider2 sh
grpcurl -v -plaintext localhost:6565 org.feuyeux.grpc.Greeter/SayBye
exit