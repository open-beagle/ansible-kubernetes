#!/bin/bash

export PATH=/opt/bin:$PATH

set -e

REGISTRY_LOCAL="{{ REGISTRY_LOCAL }}"

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
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "ppc64" ]; then
  TARGET_ARCH="ppc64le"
elif [ "$(echo $LOCAL_ARCH | head -c 6)" = "mips64" ]; then
  TARGET_ARCH="mips64le"
else
  echo "This system's architecture $(LOCAL_ARCH) isn't supported"
  TARGET_ARCH="unsupported"
fi

{% for host in groups['master'] %}
if ! (grep -q "{{ host }}" /etc/hosts); then
  echo "{{ hostvars[host]['ansible_facts'][IFACE]['ipv4']['address'] }} {{ host }}" >>/etc/hosts
fi
{% endfor %}

if ! [ -e /etc/kubernetes/downloads/etcdctl-linux-$REGISTRY_VERSION_ETCDCTL ]; then

  docker run -v /etc/kubernetes/downloads:/data/output \
    --rm --entrypoint=sh \
    $REGISTRY_LOCAL/$REGISTRY_REPO_ETCDCTL:$REGISTRY_VERSION_ETCDCTL \
    -c 'cp /usr/local/bin/etcdctl /data/output/etcdctl'
  mv /etc/kubernetes/downloads/etcdctl /etc/kubernetes/downloads/etcdctl-linux-$REGISTRY_VERSION_ETCDCTL

  chmod +x /etc/kubernetes/downloads/etcdctl-linux-$REGISTRY_VERSION_ETCDCTL
  rm -rf /opt/bin/etcdctl /usr/local/bin/etcdctl
  ln -s /etc/kubernetes/downloads/etcdctl-linux-$REGISTRY_VERSION_ETCDCTL /opt/bin/etcdctl
  ln -s /etc/kubernetes/downloads/etcdctl-linux-$REGISTRY_VERSION_ETCDCTL /usr/local/bin/etcdctl

fi

if ! [ -e /etc/kubernetes/downloads/etcdutl-linux-$REGISTRY_VERSION_ETCDCTL ]; then

  docker run -v /etc/kubernetes/downloads:/data/output \
    --rm --entrypoint=sh \
    $REGISTRY_LOCAL/$REGISTRY_REPO_ETCDCTL:$REGISTRY_VERSION_ETCDCTL \
    -c 'cp /usr/local/bin/etcdutl /data/output/etcdutl'
  mv /etc/kubernetes/downloads/etcdutl /etc/kubernetes/downloads/etcdutl-linux-$REGISTRY_VERSION_ETCDCTL

  chmod +x /etc/kubernetes/downloads/etcdutl-linux-$REGISTRY_VERSION_ETCDCTL
  rm -rf /opt/bin/etcdutl /usr/local/bin/etcdutl
  ln -s /etc/kubernetes/downloads/etcdutl-linux-$REGISTRY_VERSION_ETCDCTL /opt/bin/etcdutl
  ln -s /etc/kubernetes/downloads/etcdutl-linux-$REGISTRY_VERSION_ETCDCTL /usr/local/bin/etcdutl

fi
