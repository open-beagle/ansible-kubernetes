#!/bin/bash 

set -ex

# HTTPS服务器
HTTP_SERVER="${HTTP_SERVER:-https://cache.wodcloud.com/kubernetes}"
# 平台架构
TARGET_ARCH="${TARGET_ARCH:-amd64}"
# K8S版本
K8S_VERSION="${K8S_VERSION:-v1.24.9}"

LOCAL_KERNEL=$(uname -r | head -c 3)
LOCAL_ARCH=$(uname -m)

if [ "$LOCAL_ARCH" = "x86_64" ]; then
  TARGET_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "ppc64le" ]; then
  # TARGET_ARCH="ppc64le"
  TARGET_ARCH="unsupported"
elif [ "$LOCAL_ARCH" = "mips64" ]; then
  # TARGET_ARCH="mips64le"
  TARGET_ARCH="unsupported"
else
  echo "This system's architecture $(LOCAL_ARCH) isn't supported"
  TARGET_ARCH="unsupported"
fi

if ! [ -e /etc/kubernetes/ansible/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz ]; then
mkdir -p /etc/kubernetes/ansible
# 下载文件
# ansible-docker-v1.24.9-amd64.tgz 68MB
curl $HTTP_SERVER/k8s/ansible/$TARGET_ARCH/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz > /etc/kubernetes/ansible/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz
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
# 依赖镜像 ansible-kubernetes-images-v1.24.9-amd64.tgz 1526MB
curl $HTTP_SERVER/k8s/ansible/$TARGET_ARCH/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz > /etc/kubernetes/ansible/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz
fi

if ! [ -e /etc/kubernetes/ansible/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz ]; then
mkdir -p /etc/kubernetes/ansible
# 下载文件
# 安装脚本 ansible-kubernetes-v1.24.9-amd64.tgz 276MB
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