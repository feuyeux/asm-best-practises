#!/usr/bin/env bash
grpcurl -v -plaintext localhost:6001 list
grpcurl -v -plaintext localhost:7001 list
echo "localhost:6001/hello/eric:"
grpcurl -v -plaintext -d @ localhost:6001 org.feuyeux.grpc.Greeter/SayHello <<EOM
{
  "name":"eric"
}
EOM
echo
echo "localhost:7001/hello/eric"
grpcurl -v -plaintext -d @ localhost:7001 org.feuyeux.grpc.Greeter/SayHello <<EOM
{
  "name":"eric"
}
EOM
echo
echo "localhost:6001/bye"
grpcurl -v -plaintext localhost:6001 org.feuyeux.grpc.Greeter/SayBye
echo
echo "localhost:7001/bye"
grpcurl -v -plaintext localhost:7001 org.feuyeux.grpc.Greeter/SayBye
