#!/bin/bash 

set -ex

# HTTPS服务器
HTTP_SERVER="${HTTP_SERVER:-https://cache.wodcloud.com/kubernetes}"
# 平台架构
TARGET_ARCH="${TARGET_ARCH:-amd64}"
# K8S版本
K8S_VERSION="${K8S_VERSION:-1.24.7}"

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

if ! [ -e /etc/kubernetes/ansible/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz ]; then
mkdir -p /etc/kubernetes/ansible
# 下载文件
# 安装镜像 ansible-kubernetes-images-v1.24.7-amd64.tgz 1526MB
curl $HTTP_SERVER/k8s/ansible/$TARGET_ARCH/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz > /etc/kubernetes/ansible/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz
fi

if ! [ -e /etc/kubernetes/ansible/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz ]; then
mkdir -p /etc/kubernetes/ansible
# 下载文件
# 安装脚本 ansible-kubernetes-v1.24.7-amd64.tgz 276MB
curl $HTTP_SERVER/k8s/ansible/$TARGET_ARCH/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz > /etc/kubernetes/ansible/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz
fi

if ! [ -e /etc/kubernetes/ansible/.ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH ]; then
# 加载镜像
docker load -i /etc/kubernetes/ansible/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz
touch /etc/kubernetes/ansible/.ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH
fi

docker run \
-t \
--rm \
-v /etc/kubernetes/ansible/hosts.ini:/etc/ansible/hosts \
-v /etc/kubernetes/ansible/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz:/etc/ansible/linux/roles/wod.registry/files/images/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz \
-w /etc/ansible/linux \
registry.cn-qingdao.aliyuncs.com/wod/ansible-kubernetes:$K8S_VERSION-$TARGET_ARCH \
ansible-playbook 1.install.yml