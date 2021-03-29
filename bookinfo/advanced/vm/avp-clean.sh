#!/usr/bin/env sh
docker stop $(docker ps -a -q) >/dev/null 2>&1
docker rm $(docker ps -a -q) >/dev/null 2>&1
docker rmi -f $(docker images | grep none | awk "{print $3}") >/dev/null 2>&1
echo "nameserver 223.5.5.5" >/etc/resolv.conf
echo "nameserver 223.6.6.6" >>/etc/resolv.conf
