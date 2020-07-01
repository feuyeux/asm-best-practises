#!/usr/bin/env bash

IP=39.106.142.220
echo "Ingress gateway ip:$IP"
curl http://$IP:7001/hello/feuyeux
echo
curl http://$IP:7001/bye
echo
rm -f result
echo "Start test in loop:"
for ((i = 1; i <= 100; i++)); do
  curl -s $IP:7001/hello/feuyeux > /dev/null
done
for ((i = 1; i <= 10; i++)); do
  curl -s $IP:7001/hello/feuyeux >> result
  echo "" >>result
done
sort result | uniq -c | sort -nrk1
rm -f result
echo
for ((i = 1; i <= 100; i++)); do
  curl -s $IP:7001/bye > /dev/null
done
for ((i = 1; i <= 10; i++)); do
  curl -s $IP:7001/bye >> result
  echo "" >>result
done
sort result | uniq -c | sort -nrk1
echo
rm -f result
echo "Done."
