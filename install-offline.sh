#!/bin/bash

set -ex

# HTTPS服务器
HTTP_SERVER="${HTTP_SERVER:-https://cache.wodcloud.com}"
# 平台架构
TARGET_ARCH="${TARGET_ARCH:-amd64}"
# K8S版本
K8S_VERSION="${K8S_VERSION:-v1.24.17}"
# K8S发布版本
K8S_RELEASE="${K8S_VERSION%.*}"

LOCAL_KERNEL=$(uname -r | head -c 3)
LOCAL_ARCH=$(uname -m)

if [ "$LOCAL_ARCH" = "x86_64" ]; then
  TARGET_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  TARGET_ARCH="arm64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "ppc64" ]; then
  # TARGET_ARCH="ppc64le"
  TARGET_ARCH="unsupported"
elif [ "$(echo $LOCAL_ARCH | head -c 6)" = "mips64" ]; then
  TARGET_ARCH="mips64le"
else
  echo "This system's architecture $(LOCAL_ARCH) isn't supported"
  TARGET_ARCH="unsupported"
fi

if ! [ -e /etc/kubernetes/ansible/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz ]; then
  mkdir -p /etc/kubernetes/ansible
  # 下载文件
  # ansible-docker-$K8S_VERSION-amd64.tgz 68MB
  curl $HTTP_SERVER/kubernetes/k8s/ansible/$K8S_RELEASE/$TARGET_ARCH/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz >/etc/kubernetes/ansible/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz
fi

if ! [ -e /opt/bin/docker ]; then
  mkdir -p /opt/docker
  # 解压文件
  tar xzvf /etc/kubernetes/ansible/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz -C /opt/docker
  # 安装Docker
  bash /opt/docker/install.sh
fi

if ! [ -e /etc/kubernetes/ansible/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz ]; then
  mkdir -p /etc/kubernetes/ansible
  # 下载文件
  # 依赖镜像 ansible-kubernetes-images-$K8S_VERSION-amd64.tgz 1526MB
  curl $HTTP_SERVER/kubernetes/k8s/ansible/$K8S_RELEASE/$TARGET_ARCH/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz >/etc/kubernetes/ansible/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz
fi

if ! [ -e /etc/kubernetes/ansible/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz ]; then
  mkdir -p /etc/kubernetes/ansible
  # 下载文件
  # 安装脚本 ansible-kubernetes-$K8S_VERSION-amd64.tgz 276MB
  curl $HTTP_SERVER/kubernetes/k8s/ansible/$K8S_RELEASE/$TARGET_ARCH/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz >/etc/kubernetes/ansible/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz
fi

# 加载镜像
docker load -i /etc/kubernetes/ansible/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz

if ! [ -e /etc/kubernetes/ansible/beagle.yaml ]; then
  cat >/etc/kubernetes/ansible/beagle.yaml <<-EOF
## REGISTRY_LOCAL , Docker镜像服务器
## 安装过程种使用的容器镜像服务器
REGISTRY_LOCAL: 'registry.beagle.default:6444/k8s'
EOF
fi

docker run \
  -t \
  --rm \
  -v /etc/kubernetes/ansible/hosts.ini:/etc/ansible/hosts \
  -v /etc/kubernetes/ansible/beagle.yaml:/etc/ansible/linux/beagle_vars/beagle.yaml \
  -v /etc/kubernetes/ansible/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz:/etc/ansible/linux/roles/wod.registry/files/images/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz \
  -w /etc/ansible/linux \
  registry.cn-qingdao.aliyuncs.com/wod/ansible-kubernetes:$K8S_VERSION-$TARGET_ARCH \
  ansible-playbook 1.install.yml \
  --extra-vars "@./beagle_vars/beagle.yaml"
