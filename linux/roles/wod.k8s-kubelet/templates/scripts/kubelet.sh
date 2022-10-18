#!/bin/bash

set -e

REGISTRY_LOCAL="{{ REGISTRY_LOCAL }}"
REGISTRY_REPO="{{ K8S_IMAGES['KUBELET']['NAME'] }}"
REGISTRY_VERSION="{{ K8S_IMAGES['KUBELET']['VERSION'] }}{{ "-%s" | format(K8S_ARCH) | replace("-amd64", "") }}"
PAUSE_IMAGE="${PAUSE_IMAGE:-{{ PAUSE_IMAGE }}}"

mkdir -p /etc/kubernetes/downloads
mkdir -p /etc/kubernetes/config
mkdir -p /opt/bin

if ! [ -e /etc/kubernetes/downloads/kubelet-$REGISTRY_VERSION ]; then
  rm -rf /opt/bin/kubelet
  docker run -v /etc/kubernetes/downloads:/data/output \
    --rm --entrypoint=sh \
    $REGISTRY_LOCAL/$REGISTRY_REPO:$REGISTRY_VERSION \
    -c 'cp /usr/local/bin/kubelet /data/output/kubelet'
  mv /etc/kubernetes/downloads/kubelet /etc/kubernetes/downloads/kubelet-$REGISTRY_VERSION
  chmod +x /etc/kubernetes/downloads/kubelet-$REGISTRY_VERSION
  ln -s /etc/kubernetes/downloads/kubelet-$REGISTRY_VERSION /opt/bin/kubelet
  systemctl daemon-reload && systemctl enable k8s-kubelet && systemctl restart k8s-kubelet
fi
