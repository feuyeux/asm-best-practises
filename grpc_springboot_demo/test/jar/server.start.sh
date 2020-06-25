#!/usr/bin/env bash
export SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/"
cd $SCRIPTPATH
cd ../..
mvn clean install -DskipTests -U
java -jar provider/target/provider-1.0.0.jar