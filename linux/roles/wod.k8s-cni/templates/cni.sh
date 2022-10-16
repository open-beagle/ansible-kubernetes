#!/bin/bash 

set -e  

# cni-plugins-linux-amd64-v0.8.7.tgz

REGISTRY_LOCAL="{{ REGISTRY_LOCAL }}"
REGISTRY_REPO="{{ K8S_IMAGES['KUBE-CNI-PLUGINS']['NAME'] }}"
REGISTRY_VERSION="{{ K8S_IMAGES['KUBE-CNI-PLUGINS']['VERSION'] }}{{ '-%s' | format(K8S_ARCH) | replace('-amd64', '') }}"

mkdir -p /opt/cni/bin /etc/kubernetes/downloads

LOCAL_ARCH=$(uname -m)

if [ "$LOCAL_ARCH" = "x86_64" ]; then
  TARGET_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "ppc64le" ]; then
  TARGET_ARCH="ppc64le"
elif [ "$LOCAL_ARCH" = "mips64" ]; then
  TARGET_ARCH="mips64le"
else
  echo "This system's architecture $(LOCAL_ARCH) isn't supported"
  TARGET_ARCH="unsupported"
fi

if ! [ -e /etc/kubernetes/downloads/cni-plugins-linux-$REGISTRY_VERSION ]; then
  if ! [ -d "/opt/cni/bin" ]; then
    mv "/opt/cni/bin" "/opt/cni/bin-bak"
  fi
  docker run -v /opt/cni/bin:/data/output --rm $REGISTRY_LOCAL/$REGISTRY_REPO:$REGISTRY_VERSION
  touch /etc/kubernetes/downloads/cni-plugins-linux-$REGISTRY_VERSION
  echo 'cni bin download completed!'
fi
