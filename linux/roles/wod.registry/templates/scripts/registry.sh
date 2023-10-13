#!/bin/bash

set -e

mkdir -p /etc/kubernetes/downloads
mkdir -p {{ K8S_DATA_PATH }}/registry
mkdir -p /opt/bin

if ! [ -e /etc/kubernetes/services/k8s-registry/.beagle_registry_version_{{ BEAGLE_REGISTRY_VERSION }} ]; then
  touch /etc/kubernetes/services/k8s-registry/.beagle_registry_version_{{ BEAGLE_REGISTRY_VERSION }}
fi

if [ -e /tmp/registry/images ]; then
for file in `find /tmp/registry/images -name "*.tgz"`; do  
  tar xzvf $file -C {{ K8S_DATA_PATH }}/registry
done
rm -rf /tmp/registry/images
fi

if [ -e /tmp/registry/bin ]; then
for file in `find /tmp/registry/bin -name "registry-v*"`; do
  rm -rf /opt/bin/registry
  filename=$(basename $file)
  mv /tmp/registry/bin/$filename /etc/kubernetes/downloads/$filename
  chmod +x /etc/kubernetes/downloads/$filename
  ln -s /etc/kubernetes/downloads/$filename /opt/bin/registry
done
fi

if ! (grep -q "kubernetes.beagle.default" /etc/hosts) ; then
  echo "127.0.0.1 kubernetes.beagle.default" >> /etc/hosts
fi
sed -i --expression "s?.*kubernetes.beagle.default?127.0.0.1 kubernetes.beagle.default?" /etc/hosts

if ! (grep -q "registry.beagle.default" /etc/hosts) ; then
  echo "127.0.0.1 registry.beagle.default" >> /etc/hosts
fi
sed -i --expression "s?.*registry.beagle.default?127.0.0.1 registry.beagle.default?" /etc/hosts

if ! [ -e /etc/kubernetes/services/k8s-registry/registry.beagle.default.key ]; then
  /usr/bin/openssl genrsa \
                  -out /etc/kubernetes/services/k8s-registry/registry.beagle.default.key 2048

  /usr/bin/openssl req -new \
                  -key /etc/kubernetes/services/k8s-registry/registry.beagle.default.key \
                  -out /etc/kubernetes/services/k8s-registry/registry.beagle.default.csr \
                  -subj "/CN=registry/C=CN/ST=BeiJing/L=Beijing/O=beaglecloud/OU=System" \
                  -config /etc/kubernetes/services/k8s-registry/registry.beagle.default.cnf
                  
  /usr/bin/openssl x509 -req \
                  -in /etc/kubernetes/services/k8s-registry/registry.beagle.default.csr \
                  -CA /etc/kubernetes/ssl/ca.crt \
                  -CAkey /etc/kubernetes/ssl/ca.key \
                  -CAcreateserial -out /etc/kubernetes/services/k8s-registry/registry.beagle.default.crt \
                  -days 3650 -extensions v3_req \
                  -extfile /etc/kubernetes/services/k8s-registry/registry.beagle.default.cnf
fi

if ! [ -e /etc/kubernetes/services/k8s-registry/registry.beagle.default.crt ]; then
  /usr/bin/openssl req -new \
                  -key /etc/kubernetes/services/k8s-registry/registry.beagle.default.key \
                  -out /etc/kubernetes/services/k8s-registry/registry.beagle.default.csr \
                  -subj "/CN=registry/C=CN/ST=BeiJing/L=Beijing/O=beaglecloud/OU=System" \
                  -config /etc/kubernetes/services/k8s-registry/registry.beagle.default.cnf
                  
  /usr/bin/openssl x509 -req \
                  -in /etc/kubernetes/services/k8s-registry/registry.beagle.default.csr \
                  -CA /etc/kubernetes/ssl/ca.crt \
                  -CAkey /etc/kubernetes/ssl/ca.key \
                  -CAcreateserial -out /etc/kubernetes/services/k8s-registry/registry.beagle.default.crt \
                  -days 3650 -extensions v3_req \
                  -extfile /etc/kubernetes/services/k8s-registry/registry.beagle.default.cnf
fi

systemctl daemon-reload && systemctl enable k8s-registry.service && systemctl restart k8s-registry.service