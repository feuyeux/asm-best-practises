#!/usr/bin/env bash

docker exec -it provider2 sh
grpcurl -v -plaintext localhost:6565 org.feuyeux.grpc.Greeter/SayBye
exit