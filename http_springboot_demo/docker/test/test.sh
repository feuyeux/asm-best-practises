#!/usr/bin/env bash
echo "localhost:7001/hello/eric:"
curl localhost:7001/hello/eric
echo
echo "localhost:8001/hello/eric"
curl localhost:8001/hello/eric
echo
echo "localhost:7001/bye"
curl localhost:7001/bye
echo
echo "localhost:8001/bye"
curl localhost:8001/bye

for ((i = 1; i <= 100; i++)); do
  time curl localhost:7001/hello/eric
done