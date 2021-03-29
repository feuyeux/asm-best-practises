#!/usr/bin/env sh
set -e
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
sh 1.install_istio.sh
sh 2.deploy_bookinfo.sh
sh 3.install_skywalking.sh