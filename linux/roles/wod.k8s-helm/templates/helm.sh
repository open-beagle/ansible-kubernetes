#!/bin/bash 

set -e  

REGISTRY_LOCAL="{{ REGISTRY_LOCAL }}"
REGISTRY_REPO="{{ K8S_IMAGES['HELM']['NAME'] }}"
REGISTRY_VERSION="{{ K8S_IMAGES['HELM']['VERSION'] }}{{ "-%s" | format(K8S_ARCH) | replace("-amd64", "") }}"

mkdir -p /etc/kubernetes/downloads
mkdir -p /opt/bin

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

if ! [ -e /etc/kubernetes/downloads/helm-linux-$REGISTRY_VERSION ]; then

  docker run -v /etc/kubernetes/downloads:/tmp/downloads \
    --rm --entrypoint=sh \
    $REGISTRY_LOCAL/$REGISTRY_REPO:$REGISTRY_VERSION \
    -c 'cp /usr/local/bin/helm /tmp/downloads/helm'
  mv /etc/kubernetes/downloads/helm /etc/kubernetes/downloads/helm-linux-$REGISTRY_VERSION
  chmod +x /etc/kubernetes/downloads/helm-linux-$REGISTRY_VERSION
  rm -rf /opt/bin/helm
  ln -s /etc/kubernetes/downloads/helm-linux-$REGISTRY_VERSION /opt/bin/helm
  
fi

if ! [ -x "$(command -v helm)" ]; then
  ln -s /opt/bin/helm /usr/bin/helm
fi
