#!/usr/bin/env bash

source scripts/my-functions.sh

echo
echo "Starting eureka..."

docker run -d --rm --name eureka-server \
  -p 8761:8761 --network kafka_default \
      --health-cmd="curl -f http://localhost:8761/actuator/health || exit 1" --health-start-period=1m \
  kafka/eureka-server

wait_for_container_log "eureka" "Started"

echo
echo "Starting producer-api..."

docker run -d --rm --name producer \
  -p 9080:9080 --network=kafka_default \
  -e KAFKA_HOST=kafka -e KAFKA_PORT=9092 -e EUREKA_HOST=eureka-server -e ZIPKIN_HOST=zipkin \
  --health-cmd="curl -f http://localhost:9080/actuator/health || exit 1" --health-start-period=1m \
  kafka/producer

wait_for_container_log "producer-api" "Started"

echo
echo "Starting consumer-api..."

docker run -d --rm --name consumer \
  -p 9081:9081 --network=kafka_default \
  -e KAFKA_HOST=kafka -e KAFKA_PORT=9092 -e EUREKA_HOST=eureka-server -e ZIPKIN_HOST=zipkin \
  --health-cmd="curl -f http://localhost:9081/actuator/health || exit 1" --health-start-period=1m \
  kafka/consumer

wait_for_container_log "consumer-api" "Started"
