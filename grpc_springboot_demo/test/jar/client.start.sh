#!/usr/bin/env bash
export SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/"
cd "$SCRIPT_PATH"
cd ../..
mvn clean install -DskipTests -U
##
