#!/bin/bash

set -ex

TARGETARCH=amd64

rm -rf ./linux/roles/wod.cilium/files/*.tgz
CILIUM_VERSION=1.14.14
curl https://cache.wodcloud.com/kubernetes/k8s/charts/beagle-cilium-$CILIUM_VERSION.tgz >./linux/roles/wod.cilium/files/beagle-cilium-$CILIUM_VERSION.tgz

rm -rf ./linux/roles/wod.docker/files/*.tgz
DOCKER_VERSION=27.3.1
curl https://cache.wodcloud.com/kubernetes/k8s/docker/$TARGETARCH/docker-$DOCKER_VERSION.tgz >./linux/roles/wod.docker/files/docker-$DOCKER_VERSION.tgz
curl https://cache.wodcloud.com/kubernetes/k8s/docker/install.sh >./linux/roles/wod.docker/files/install.sh
curl https://cache.wodcloud.com/kubernetes/k8s/docker/uninstall.sh >./linux/roles/wod.docker/files/uninstall.sh

sed -i --expression "s?DOCKER_VERSION=.*?DOCKER_VERSION=\"\$\{DOCKER_VERSION\:-$DOCKER_VERSION\}\"?" ./linux/roles/wod.docker/files/install.sh

rm -rf ./linux/roles/wod.registry/files/bin/registry-*
REGISTRY_VERSION=v2.8.1
docker run -it --rm \
  --entrypoint=sh \
  -e REGISTRY_VERSION=$REGISTRY_VERSION \
  -v $PWD/linux/roles/wod.registry/files/bin:/data/output \
  registry.cn-qingdao.aliyuncs.com/wod/registry:$REGISTRY_VERSION \
  -c "cp /usr/local/bin/registry /data/output/registry-$REGISTRY_VERSION"

rm -rf ./linux/roles/wod.gateway/files/gateway-*
GATEWAY_VERSION=v6.1.1
docker run -it --rm \
  --entrypoint=sh \
  -e GATEWAY_VERSION=$GATEWAY_VERSION \
  -v $PWD/linux/roles/wod.gateway/files:/data/output \
  registry.cn-qingdao.aliyuncs.com/wod/awecloud-gateway:$GATEWAY_VERSION \
  -c "cp /usr/local/bin/gateway /data/output/gateway-$GATEWAY_VERSION"
