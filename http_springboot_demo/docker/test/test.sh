#!/usr/bin/env bash
curl localhost:7001/hello/eric
echo
curl localhost:8001/hello/eric
echo
curl localhost:7001/bye
echo
curl localhost:8001/bye
