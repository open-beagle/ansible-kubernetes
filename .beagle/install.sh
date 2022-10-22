#!/bin/bash 

-ex

CILIUM_VERSION=1.11.9
curl https://cache.wodcloud.com/kubernetes/k8s/charts/beagle-cilium-$CILIUM_VERSION.tgz > ./linux/roles/wod.cilium/files/beagle-cilium-$CILIUM_VERSION.tgz

DOCKER_VERSION=20.10.19
curl https://cache.wodcloud.com/kubernetes/k8s/docker/amd64/docker-$DOCKER_VERSION.tgz > ./linux/roles/wod.docker/files/docker-$DOCKER_VERSION.tgz
curl https://cache.wodcloud.com/kubernetes/k8s/docker/install.sh > ./linux/roles/wod.docker/templates/install.sh
curl https://cache.wodcloud.com/kubernetes/k8s/docker/uninstall.sh > ./linux/roles/wod.docker/templates/uninstall.sh

REGISTRY_VERSION=v2.8.1
docker run -it --rm \
  --entrypoint=sh \
  -e REGISTRY_VERSION=$REGISTRY_VERSION \
  -v $PWD/linux/roles/wod.registry/files/bin:/data/output \
  registry.cn-qingdao.aliyuncs.com/wod/registry:$REGISTRY_VERSION \
  -c "cp /usr/local/bin/registry /data/output/registry-$REGISTRY_VERSION"

ENVOY_VERSION=1.23.1
docker run -it --rm \
  --entrypoint=sh \
  -e ENVOY_VERSION=$ENVOY_VERSION \
  -v $PWD/linux/roles/wod.envoy/files:/data/output \
  registry.cn-qingdao.aliyuncs.com/wod/envoy:$ENVOY_VERSION \
  -c "cp /usr/local/bin/envoy /data/output/envoy-$ENVOY_VERSION"