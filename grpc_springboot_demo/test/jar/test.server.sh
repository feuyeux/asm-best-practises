#!/usr/bin/env bash
echo ":: list ::"
grpcurl -v -plaintext localhost:6565 list
grpcurl -plaintext localhost:6565 list org.feuyeux.grpc.Greeter
grpcurl -plaintext localhost:6565 describe org.feuyeux.grpc.Greeter.SayHello

echo
echo ":: SayHello ::"
grpcurl -v -plaintext -d @ localhost:6565 org.feuyeux.grpc.Greeter/SayHello <<EOM
{
  "name":"feuyeux"
}
EOM
echo
echo ":: SayBye ::"
grpcurl -v -plaintext localhost:6565 org.feuyeux.grpc.Greeter/SayBye