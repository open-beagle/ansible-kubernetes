#!/bin/bash

export PATH=/opt/bin:$PATH

set -ex

# HTTPS服务器
HTTP_SERVER="${HTTP_SERVER:-https://cache.ali.wodcloud.com}"
# 平台架构
TARGET_ARCH="${TARGET_ARCH:-amd64}"
# K8S版本
K8S_VERSION="${K8S_VERSION:-v1.32.10}"
# K8S发布版本
K8S_RELEASE="${K8S_VERSION#v}"
K8S_RELEASE="${K8S_RELEASE%.*}"
# ANSIBLE-K8S版本自动检测
if [ -z "${ANSIBLE_K8S_VERSION}" ]; then
  # 检查是否存在latest版本的文件
  if [ -f "/etc/kubernetes/ansible/ansible-kubernetes-latest-${TARGET_ARCH}.tgz" ]; then
    ANSIBLE_K8S_VERSION="latest"
  else
    # 搜索所有ansible-kubernetes-*-${TARGET_ARCH}.tgz文件
    AVAILABLE_FILES=$(ls /etc/kubernetes/ansible/ansible-kubernetes-*-${TARGET_ARCH}.tgz 2>/dev/null | sed "s|/etc/kubernetes/ansible/ansible-kubernetes-||g" | sed "s|-${TARGET_ARCH}.tgz||g" | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V)
    
    # 找到最大的版本
    BEST_VERSION=""
    for version in $AVAILABLE_FILES; do
      BEST_VERSION="$version"
    done
    
    # 如果找到版本则使用，否则使用默认值latest
    if [ -n "$BEST_VERSION" ]; then
      ANSIBLE_K8S_VERSION="$BEST_VERSION"
    else
      ANSIBLE_K8S_VERSION="latest"
    fi
  fi
else
  ANSIBLE_K8S_VERSION="${K8S_VERSION}"
fi

echo "Using ANSIBLE_K8S_VERSION: $ANSIBLE_K8S_VERSION"

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
  curl -sL $HTTP_SERVER/kubernetes/ansible/ansible-kubernetes-images-${K8S_VERSION}-${TARGET_ARCH}.tgz >/etc/kubernetes/ansible/ansible-kubernetes-images-${K8S_VERSION}-${TARGET_ARCH}.tgz
fi

if ! [ -e /etc/kubernetes/ansible/ansible-kubernetes-${ANSIBLE_K8S_VERSION}-${TARGET_ARCH}.tgz ]; then
  mkdir -p /etc/kubernetes/ansible
  # 下载文件
  # 安装脚本 ansible-kubernetes-${ANSIBLE_K8S_VERSION}-amd64.tgz 276MB
  curl -sL $HTTP_SERVER/kubernetes/ansible/ansible-kubernetes-${ANSIBLE_K8S_VERSION}-${TARGET_ARCH}.tgz >/etc/kubernetes/ansible/ansible-kubernetes-${ANSIBLE_K8S_VERSION}-${TARGET_ARCH}.tgz
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
  --extra-vars "@./vars/${K8S_RELEASE}.yml"
