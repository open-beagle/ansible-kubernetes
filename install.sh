#!/bin/bash

export PATH=/opt/bin:$PATH

set -ex

# K8S版本
K8S_VERSION="${K8S_VERSION:-v1.30.5}"

if ! [ -e /etc/kubernetes/ansible/beagle.yaml ]; then
  cat >/etc/kubernetes/ansible/beagle.yaml <<-EOF
REGISTRY_LOCAL: 'registry.cn-qingdao.aliyuncs.com/wod'
K8S_VERSION: "${K8S_VERSION}"
EOF
fi

docker run \
  -t \
  --rm \
  -v /etc/kubernetes/ansible/hosts.ini:/etc/ansible/hosts \
  -v /etc/kubernetes/ansible/beagle.yaml:/etc/ansible/linux/beagle_vars/beagle.yaml \
  -w /etc/ansible/linux \
  registry.cn-qingdao.aliyuncs.com/wod/ansible-kubernetes:latest \
  ansible-playbook 1.install.yml \
  --extra-vars "@./beagle_vars/beagle.yaml"
