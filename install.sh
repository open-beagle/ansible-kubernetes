#!/bin/bash

export PATH=/opt/bin:$PATH

set -ex

# K8S版本
K8S_VERSION="${K8S_VERSION:-v1.30.14}"
# K8S发布版本
K8S_RELEASE="${K8S_VERSION#v}"
K8S_RELEASE="${K8S_RELEASE%.*}"
# ANSIBLE-K8S版本
ANSIBLE_K8S_VERSION="${ANSIBLE_K8S_VERSION:-latest}"

if ! [ -e /etc/kubernetes/ansible/ansible-kubernetes.yml ]; then
  cat >/etc/kubernetes/ansible/ansible-kubernetes.yml <<-EOF
REGISTRY_LOCAL: 'registry.cn-qingdao.aliyuncs.com/wod'
K8S_VERSION: "${K8S_VERSION}"
EOF
fi

docker run \
  -t \
  --rm \
  -v /etc/kubernetes/ansible/ansible-kubernetes.ini:/etc/ansible/hosts \
  -v /etc/kubernetes/ansible/ansible-kubernetes.yml:/etc/ansible/linux/beagle_vars/ansible-kubernetes.yml \
  -w /etc/ansible/linux \
  registry.cn-qingdao.aliyuncs.com/wod/ansible-kubernetes:${ANSIBLE_K8S_VERSION} \
  ansible-playbook 1.install.yml \
  --extra-vars "@./beagle_vars/ansible-kubernetes.yml" \
  --extra-vars "@./vars/${K8S_RELEASE}.yml"
