#!/bin/bash 

set -e  

REGISTRY_LOCAL="{{ REGISTRY_LOCAL }}"

REGISTRY_REPO_ETCD="{{ K8S_IMAGES['ETCD']['NAME'] }}"
REGISTRY_VERSION_ETCD="{{ K8S_IMAGES['ETCD']['VERSION'] }}{{ "-%s" | format(K8S_ARCH) | replace("-amd64", "") }}"

REGISTRY_REPO_ETCDCTL="{{ K8S_IMAGES['ETCDCTL']['NAME'] }}"
REGISTRY_VERSION_ETCDCTL="{{ K8S_IMAGES['ETCDCTL']['VERSION'] }}{{ "-%s" | format(K8S_ARCH) | replace("-amd64", "") }}"

DATA_PATH="{{ ETCD_DATA_PATH }}"

mkdir -p $DATA_PATH
mkdir -p /opt/bin

chmod 0700 $DATA_PATH

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

if ! [ -e /etc/kubernetes/downloads/etcdctl-linux-$REGISTRY_VERSION_ETCDCTL ]; then

  docker run -v /etc/kubernetes/downloads:/data/output \
    --rm --entrypoint=sh \
    $REGISTRY_LOCAL/$REGISTRY_REPO_ETCDCTL:$REGISTRY_VERSION_ETCDCTL \
    -c 'cp /usr/local/bin/etcdctl /data/output/etcdctl'
  mv /etc/kubernetes/downloads/etcdctl /etc/kubernetes/downloads/etcdctl-linux-$REGISTRY_VERSION_ETCDCTL

  chmod +x /etc/kubernetes/downloads/etcdctl-linux-$REGISTRY_VERSION_ETCDCTL
  rm -rf /opt/bin/etcdctl
  ln -s /etc/kubernetes/downloads/etcdctl-linux-$REGISTRY_VERSION_ETCDCTL /opt/bin/etcdctl
  
fi

if ! [ -x "$(command -v etcdctl)" ]; then
  rm -rf /opt/bin/etcdctl
  ln -s /etc/kubernetes/downloads/etcdctl-linux-$REGISTRY_VERSION_ETCDCTL /opt/bin/etcdctl
fi  
