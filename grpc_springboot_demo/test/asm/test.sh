#!/usr/bin/env bash
HOST=47.92.130.26
echo ":::: ${HOST}:9001/hello/feuyeux ::::"
curl -i "${HOST}:9001/hello/feuyeux"
echo
echo
echo ":::: ${HOST}:9001/bye ::::"
curl -i "${HOST}:9001/bye"