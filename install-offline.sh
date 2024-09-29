#!/bin/bash

export PATH=/opt/bin:$PATH

set -ex

# HTTPS服务器
HTTP_SERVER="${HTTP_SERVER:-https://cache.wodcloud.com}"
# 平台架构
TARGET_ARCH="${TARGET_ARCH:-amd64}"
# K8S版本
K8S_VERSION="${K8S_VERSION:-v1.30.5}"
# K8S发布版本
K8S_RELEASE="${K8S_VERSION#v}"
K8S_RELEASE="${K8S_RELEASE%.*}"
# ANSIBLE-K8S版本
ANSIBLE_K8S_VERSION="${ANSIBLE_K8S_VERSION:-latest}"

LOCAL_KERNEL=$(uname -r | head -c 3)
LOCAL_ARCH=$(uname -m)
if [ "$LOCAL_ARCH" = "x86_64" ]; then
  TARGET_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "loongarch64" ]; then
  TARGET_ARCH="loong64"
else
  TARGET_ARCH="unsupported"
fi
if [ "$LOCAL_ARCH" = "unsupported" ]; then
  echo "This system's architecture ${LOCAL_ARCH} isn't supported"
  exit 0
fi

if ! [ -e /etc/kubernetes/ansible/ansible-kubernetes-images-${K8S_VERSION}-${TARGET_ARCH}.tgz ]; then
  mkdir -p /etc/kubernetes/ansible
  # 下载文件
  # 依赖镜像 ansible-kubernetes-images-$K8S_VERSION-amd64.tgz 1526MB
  curl -sL $HTTP_SERVER/kubernetes/k8s/ansible/ansible-kubernetes-images-${K8S_VERSION}-${TARGET_ARCH}.tgz >/etc/kubernetes/ansible/ansible-kubernetes-images-${K8S_VERSION}-${TARGET_ARCH}.tgz
fi

if ! [ -e /etc/kubernetes/ansible/ansible-kubernetes-${ANSIBLE_K8S_VERSION}-${TARGET_ARCH}.tgz ]; then
  mkdir -p /etc/kubernetes/ansible
  # 下载文件
  # 安装脚本 ansible-kubernetes-${ANSIBLE_K8S_VERSION}-amd64.tgz 276MB
  curl -sL $HTTP_SERVER/kubernetes/k8s/ansible/ansible-kubernetes-${ANSIBLE_K8S_VERSION}-${TARGET_ARCH}.tgz >/etc/kubernetes/ansible/ansible-kubernetes-${ANSIBLE_K8S_VERSION}-${TARGET_ARCH}.tgz
fi

# 加载ansible-kubernetes镜像
docker load -i /etc/kubernetes/ansible/ansible-kubernetes-${ANSIBLE_K8S_VERSION}-${TARGET_ARCH}.tgz

# 为ansible-kubernetes准备配置文件
if [ ! -e /etc/kubernetes/ansible/ansible-kubernetes.yml ]; then
  mkdir -p /etc/kubernetes/ansible
  cat >/etc/kubernetes/ansible/ansible-kubernetes.yml <<-EOF
K8S_VERSION: "${K8S_VERSION}"
EOF
fi

# 运行ansible-kubernetes容器安装k8s
docker run \
  -t \
  --rm \
  -v /etc/kubernetes/ansible/ansible-kubernetes.ini:/etc/ansible/hosts \
  -v /etc/kubernetes/ansible/ansible-kubernetes.yml:/etc/ansible/linux/beagle_vars/ansible-kubernetes.yml \
  -v /etc/kubernetes/ansible/ansible-kubernetes-images-${K8S_VERSION}-${TARGET_ARCH}.tgz:/etc/ansible/linux/roles/wod.registry/files/images/ansible-kubernetes-images-${K8S_VERSION}-${TARGET_ARCH}.tgz \
  -w /etc/ansible/linux \
  registry.cn-qingdao.aliyuncs.com/wod/ansible-kubernetes:${ANSIBLE_K8S_VERSION}-${TARGET_ARCH} \
  ansible-playbook 1.install.yml \
  --extra-vars "@./beagle_vars/ansible-kubernetes.yml" \
  --extra-vars "@./linux/vars/${K8S_RELEASE}.yml"
