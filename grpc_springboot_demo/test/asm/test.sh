#!/usr/bin/env bash
HOST=39.106.142.220
echo ":::: ${HOST}:9001/hello/feuyeux ::::"
curl "${HOST}:9001/hello/feuyeux"
echo
echo ":::: ${HOST}:9001/bye ::::"
curl "${HOST}:9001/bye"
echo
for ((i = 1; i <= 10; i++)); do
  curl ${HOST}:9001/hello/feuyeux
  echo
done
