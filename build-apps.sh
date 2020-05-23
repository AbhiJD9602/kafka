#!/usr/bin/env bash

./gradlew :producer:clean build
./gradlew :consumer:clean build
./gradlew :eureka-server:clean build


set -eo pipefail

modules=( consumer producer eureka-server )

for module in "${modules[@]}"; do
    docker build -t "kafka/${module}:latest" ${module}
done