#!/usr/bin/env bash
docker run -d --name synapse --tmpfs /data \
    --volume="$(pwd)/integration_test/synapse/data/conciel.yaml":/data/conciel.yaml:rw \
    --volume="$(pwd)/integration_test/synapse/data/localhost.log.config":/data/localhost.log.config:rw \
    -p 80:80 matrixdotorg/synapse:latest
