#!/usr/bin/env bash

IP=39.106.171.124
echo "curl $IP:7001/hello/feuyeux"
for ((i=1; i<=10; i++))
do
  curl $IP:7001/hello/feuyeux
done