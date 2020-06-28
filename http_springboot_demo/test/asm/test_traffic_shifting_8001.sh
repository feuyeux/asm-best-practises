#!/usr/bin/env bash

IP=47.94.204.134

echo "http://$IP:8001/hello/feuyeux"
curl -s "http://$IP:8001/hello/feuyeux" >>result

if [ -s result ]; then
  cat result
  rm -f result
else
  echo "fail to access!"
  rm -f result
  exit 1
fi

echo
echo "Start test in loop:"

for ((i = 1; i <= 100; i++)); do
  curl -s $IP:8001/hello/feuyeux >>result
  echo "" >>result
done

sort result | uniq -c | sort -nrk1

rm -f result
echo "Done."
