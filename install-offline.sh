#!/bin/bash 

set -ex

# HTTPS服务器
export HTTP_SERVER=https://cache.wodcloud.com/kubernetes
# 平台架构
export TARGET_ARCH=amd64
# Docker版本
export DOCKER_VERSION=20.10.18

if ! [ -e /opt/docker/VERSION-$DOCKER_VERSION.md ]; then

# 下载文件
# docker、containerd安装包与脚本 ， docker-20.10.18.tgz 68MB
mkdir -p /opt/docker
curl $HTTP_SERVER/k8s/docker/install-20.sh > /opt/docker/install-20.sh
curl $HTTP_SERVER/k8s/docker/uninstall-20.sh > /opt/docker/uninstall-20.sh
curl $HTTP_SERVER/k8s/docker/$TARGET_ARCH/docker-$DOCKER_VERSION.tgz > /opt/docker/docker-$DOCKER_VERSION.tgz

# 安装Docker
bash /opt/docker/install-20.sh
fi

# K8S版本
export K8S_VERSION=v1.24.7

if ! [ -e /etc/kubernetes/downloads/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz ]; then
mkdir -p /etc/kubernetes/downloads
# 下载文件
# 安装镜像 ansible-kubernetes-images-v1.24.7-amd64.tgz 1526MB
# 安装脚本 ansible-kubernetes-v1.24.7-amd64.tgz 276MB
curl $HTTP_SERVER/k8s/ansible/$TARGET_ARCH/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz > /etc/kubernetes/downloads/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz
curl $HTTP_SERVER/k8s/ansible/$TARGET_ARCH/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz > /etc/kubernetes/downloads/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz

# 加载镜像
docker load -i /etc/kubernetes/downloads/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz
fi

docker run \
-t \
--rm \
-v /etc/kubernetes/config/hosts.ini:/etc/ansible/hosts \
-v /etc/kubernetes/downloads/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz:/etc/ansible/linux/roles/wod.registry/files/images/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz \
-w /etc/ansible/linux \
registry.cn-qingdao.aliyuncs.com/wod/ansible-kubernetes:v1.24.7-$TARGET_ARCH \
ansible-playbook 1.install.yml

source /etc/environment