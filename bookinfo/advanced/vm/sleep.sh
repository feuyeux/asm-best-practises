#!/usr/bin/env sh
SLEEP_REPO=governmentpaas/curl-ssl

docker run -d \
    --name=sleep \
    --network=host \
    $SLEEP_REPO /bin/sleep 3650d
