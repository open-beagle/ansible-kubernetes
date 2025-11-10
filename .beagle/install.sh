#!/bin/bash

set -ex

TARGETARCH=amd64

find ./linux/roles/wod.cilium/files -mindepth 1 -not -name '.gitkeep' -delete
CILIUM_VERSION=1.14.19
curl -sL https://cache.ali.wodcloud.com/kubernetes/charts/beagle-cilium-$CILIUM_VERSION.tgz >./linux/roles/wod.cilium/files/beagle-cilium-$CILIUM_VERSION.tgz

find ./linux/roles/wod.docker/files -mindepth 1 -not -name '.gitkeep' -delete
DOCKER_VERSION=28.3.2
curl -sL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-docker-$DOCKER_VERSION-$TARGETARCH.tgz >./linux/roles/wod.docker/files/ansible-docker-$DOCKER_VERSION.tgz
curl -sL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-docker.sh >./linux/roles/wod.docker/files/ansible-docker.sh
curl -sL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-docker-uninstall.sh >./linux/roles/wod.docker/files/ansible-docker-uninstall.sh

sed -i --expression "s?DOCKER_VERSION=.*?DOCKER_VERSION=\"\$\{DOCKER_VERSION\:-$DOCKER_VERSION\}\"?" ./linux/roles/wod.docker/files/ansible-docker.sh

find ./linux/roles/wod.registry/files/bin -mindepth 1 -not -name '.gitkeep' -delete
REGISTRY_VERSION=v2.8.1
docker run -it --rm \
  --entrypoint=sh \
  -e REGISTRY_VERSION=$REGISTRY_VERSION \
  -v $PWD/linux/roles/wod.registry/files/bin:/data/output \
  registry.cn-qingdao.aliyuncs.com/wod/registry:$REGISTRY_VERSION \
  -c "cp /usr/local/bin/registry /data/output/registry-$REGISTRY_VERSION"

find ./linux/roles/wod.gateway/files -mindepth 1 -not -name '.gitkeep' -delete
GATEWAY_VERSION=v6.1.1
docker run -it --rm \
  --entrypoint=sh \
  -e GATEWAY_VERSION=$GATEWAY_VERSION \
  -v $PWD/linux/roles/wod.gateway/files:/data/output \
  registry.cn-qingdao.aliyuncs.com/wod/awecloud-gateway:$GATEWAY_VERSION \
  -c "cp /usr/local/bin/gateway /data/output/gateway-$GATEWAY_VERSION"
