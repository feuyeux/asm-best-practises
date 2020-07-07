#!/usr/bin/env bash
echo "localhost:7001/hello/feuyeux:"
curl localhost:7001/hello/feuyeux
echo
echo "localhost:8001/hello/feuyeux"
curl localhost:8001/hello/feuyeux
echo
echo "localhost:7001/bye"
curl localhost:7001/bye
echo
echo "localhost:8001/bye"
curl localhost:8001/bye
