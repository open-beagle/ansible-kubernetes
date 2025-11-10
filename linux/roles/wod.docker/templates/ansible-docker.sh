#!/bin/sh

set -ex

HTTP_SERVER="${HTTP_SERVER:-https://cache.ali.wodcloud.com}"
DOCKER_VERSION="{{ DOCKER_VERSION }}"

if ! [ -e /opt/docker/${DOCKER_VERSION}/scripts/install.sh ]; then
  rm -rf /opt/docker/${DOCKER_VERSION}
  mkdir -p /opt/docker/${DOCKER_VERSION}
  if ! [ -e /opt/docker/ansible-docker-${DOCKER_VERSION}.tgz ]; then
    curl -fL $HTTP_SERVER/kubernetes/ansible/ansible-docker-${DOCKER_VERSION}.tgz >/opt/docker/ansible-docker-${DOCKER_VERSION}.tgz
  fi
  tar -xzvf /opt/docker/ansible-docker-${DOCKER_VERSION}.tgz -C /opt/docker/${DOCKER_VERSION}
  rm -rf /opt/docker/ansible-docker-${DOCKER_VERSION}.tgz
fi

. /opt/docker/${DOCKER_VERSION}/scripts/install.sh
