#!/usr/bin/env bash

IP=39.106.226.122
echo "curl $IP:7001/hello/feuyeux"
curl $IP:7001/hello/feuyeux
echo
echo "Start test in loop:"

for ((i = 1; i <= 100; i++)); do
  curl -s $IP:7001/hello/feuyeux >>result
  echo "" >>result
done

sort result | uniq -c | sort -nrk1
rm -f result
echo "Done."
