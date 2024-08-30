#!/bin/bash

set -e

mkdir -p /etc/kubernetes/downloads
mkdir -p /opt/bin

for file in $(find /tmp/gateway -name "gateway-*"); do
  rm -rf /opt/bin/gateway
  filename=$(basename $file)
  mv /tmp/gateway/$filename /etc/kubernetes/downloads/$filename
  chmod +x /etc/kubernetes/downloads/$filename
  ln -s /etc/kubernetes/downloads/$filename /opt/bin/gateway
done

if ! (grep -q "kubernetes.beagle.default" /etc/hosts); then
  echo "127.0.0.1 kubernetes.beagle.default" >>/etc/hosts
fi
sed -i --expression "s?.*kubernetes.beagle.default?127.0.0.1 kubernetes.beagle.default?" /etc/hosts

if ! (grep -q "registry.beagle.default" /etc/hosts); then
  echo "127.0.0.1 registry.beagle.default" >>/etc/hosts
fi
sed -i --expression "s?.*registry.beagle.default?127.0.0.1 registry.beagle.default?" /etc/hosts

systemctl daemon-reload && systemctl enable k8s-gateway.service && systemctl restart k8s-gateway.service
