#!/bin/bash 

set -ex

# HTTPS服务器
export HTTP_SERVER=https://cache.wodcloud.com/kubernetes
# 平台架构
export TARGET_ARCH=amd64
# K8S版本
export K8S_VERSION=v1.24.7

if ! [ -e /etc/kubernetes/ansible/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz ]; then
mkdir -p /opt/docker /etc/kubernetes/ansible
# 下载文件
# ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz 68MB
curl $HTTP_SERVER/k8s/ansible/$TARGET_ARCH/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz > /etc/kubernetes/ansible/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz
# 解压文件
tar xzvf /etc/kubernetes/ansible/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz -C /opt/docker
# 安装Docker
bash /opt/docker/install.sh
fi

docker run \
-t \
--rm \
-v /etc/kubernetes/ansible/hosts.ini:/etc/ansible/hosts \
-w /etc/ansible/linux \
registry.cn-qingdao.aliyuncs.com/wod/ansible-kubernetes:$K8S_VERSION-$TARGET_ARCH \
ansible-playbook 1.install.yml \
--extra-vars "REGISTRY_LOCAL=registry.cn-qingdao.aliyuncs.com/wod"