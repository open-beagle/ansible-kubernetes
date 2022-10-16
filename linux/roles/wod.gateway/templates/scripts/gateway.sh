#!/bin/bash

set -e

mkdir -p /etc/kubernetes/downloads
mkdir -p /etc/kubernetes/services/k8s-gateway
mkdir -p /opt/bin

for file in `find /tmp/gateway -name "gateway-*"`; do  
  rm -rf /opt/bin/gateway
  filename=$(basename $file)
  mv /tmp/gateway/$filename /etc/kubernetes/downloads/$filename
  chmod +x /etc/kubernetes/downloads/$filename
  ln -s /etc/kubernetes/downloads/$filename /opt/bin/gateway
done

if ! (grep -q "kubernetes.beagle.default" /etc/hosts) ; then
  echo "{{ HOST_IP }} kubernetes.beagle.default" >> /etc/hosts
fi

if ! (grep -q "registry.beagle.default" /etc/hosts) ; then
  echo "{{ HOST_IP }} registry.beagle.default" >> /etc/hosts
fi