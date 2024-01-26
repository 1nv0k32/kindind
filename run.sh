#!/bin/env bash

set +e

KINDIND_IMAGE_TAG=kindind:latest
CONTAINER_NAME=kdd

docker rm --force ${CONTAINER_NAME} &> /dev/null
docker build --tag ${KINDIND_IMAGE_TAG} --file ./Dockerfile .

docker run --detach --privileged --rm \
    --publish "127.0.0.1:22:22" \
    --publish "127.0.0.1:80:80" \
    --volume "./infra:/infra" \
    --name ${CONTAINER_NAME} \
    ${KINDIND_IMAGE_TAG}

docker exec ${CONTAINER_NAME} ansible-playbook /infra/kindind/kindind-playbook.yaml
docker exec --tty --interactive ${CONTAINER_NAME} bash
