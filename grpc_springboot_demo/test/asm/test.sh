#!/usr/bin/env bash
HOST=47.94.204.134
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
