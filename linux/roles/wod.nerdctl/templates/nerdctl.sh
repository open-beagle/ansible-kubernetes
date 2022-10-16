#!/bin/bash 

set -e  

REGISTRY_LOCAL="{{ REGISTRY_LOCAL }}"
REGISTRY_REPO="{{ K8S_IMAGES['NERDCTL']['NAME'] }}"
REGISTRY_VERSION="{{ K8S_IMAGES['NERDCTL']['VERSION'] }}{{ "-%s" | format(K8S_ARCH) | replace("-amd64", "") }}"

mkdir -p /etc/kubernetes/downloads
mkdir -p /opt/bin

LOCAL_ARCH=$(uname -m)

if ! [ -e /etc/kubernetes/downloads/nerdctl-linux-$REGISTRY_VERSION ]; then
  docker run -v /etc/kubernetes/downloads:/data/output \
    --rm --entrypoint=sh \
    $REGISTRY_LOCAL/$REGISTRY_REPO:$REGISTRY_VERSION \
    -c 'cp /usr/local/bin/nerdctl /data/output/nerdctl'
  mv /etc/kubernetes/downloads/nerdctl /etc/kubernetes/downloads/nerdctl-linux-$REGISTRY_VERSION
  chmod +x /etc/kubernetes/downloads/nerdctl-linux-$REGISTRY_VERSION
  rm -rf /opt/bin/nerdctl
  ln -s /etc/kubernetes/downloads/nerdctl-linux-$REGISTRY_VERSION /opt/bin/nerdctl       
fi

if ! [ -x "$(command -v nerdctl)" ]; then
  ln -s /opt/bin/nerdctl /usr/bin/nerdctl
fi
