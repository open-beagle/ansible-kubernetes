#!/bin/bash

set -e

mkdir -p /etc/kubernetes/downloads
mkdir -p {{ K8S_DATA_PATH }}/registry
mkdir -p /opt/bin

if [ -e /etc/kubernetes/ansible/ansible-kubernetes-images-{{ K8S_VERSION }}-{{ K8S_ARCH }}.tgz ]; then
  if ! [-d {{ K8S_DATA_PATH }}/registry/docker/registry/v2/repositories/k8s/kube-apiserver/_manifests/tags/{{ K8S_VERSION }}-beagle]; then
    tar xzvf /etc/kubernetes/ansible/ansible-kubernetes-images-{{ K8S_VERSION }}-{{ K8S_ARCH }}.tgz -C {{ K8S_DATA_PATH }}/registry
  fi
fi

if [ -e /etc/kubernetes/downloads/registry-{{ BEAGLE_REGISTRY_VERSION }} ]; then
  if ! (readlink /opt/bin/registry | grep -q "{{ BEAGLE_REGISTRY_VERSION }}"); then
    rm -rf /opt/bin/registry
    chmod +x /etc/kubernetes/downloads/$filename
    ln -s /etc/kubernetes/downloads/$filename /opt/bin/registry
  fi
fi

if ! (grep -q "kubernetes.beagle.default" /etc/hosts); then
  echo "127.0.0.1 kubernetes.beagle.default" >>/etc/hosts
fi
sed -i --expression "s?.*kubernetes.beagle.default?127.0.0.1 kubernetes.beagle.default?" /etc/hosts

if ! (grep -q "registry.beagle.default" /etc/hosts); then
  echo "127.0.0.1 registry.beagle.default" >>/etc/hosts
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
