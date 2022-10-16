#!/bin/bash

set -e

mkdir -p /etc/kubernetes/downloads
mkdir -p /opt/bin

for file in `find /tmp/envoy -name "envoy-*"`; do  
  rm -rf /opt/bin/envoy
  filename=$(basename $file)
  mv /tmp/envoy/$filename /etc/kubernetes/downloads/$filename
  chmod +x /etc/kubernetes/downloads/$filename
  ln -s /etc/kubernetes/downloads/$filename /opt/bin/envoy
done

if ! (grep -q "kubernetes.beagle.default" /etc/hosts) ; then
  echo "{{ HOST_IP }} kubernetes.beagle.default" >> /etc/hosts
fi

if ! (grep -q "registry.beagle.default" /etc/hosts) ; then
  echo "{{ HOST_IP }} registry.beagle.default" >> /etc/hosts
fi

systemctl daemon-reload && systemctl enable k8s-envoy.service && systemctl restart k8s-envoy.service