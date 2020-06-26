#!/usr/bin/env bash
for ((i = 1; i <= 10; i++)); do
  curl localhost:7001/hello/feuyeux
  echo
done
