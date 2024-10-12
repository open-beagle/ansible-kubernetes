#!/bin/bash 

set -e  

HTTP_SERVER="${HTTP_SERVER:-https://cache.ali.wodcloud.com}" 

LOCAL_KERNEL=$(uname -r | head -c 3)
LOCAL_ARCH=$(uname -m)

if [ "$LOCAL_ARCH" = "x86_64" ]; then
  TARGET_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  TARGET_ARCH="arm64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "ppc64" ]; then
  TARGET_ARCH="ppc64le"
elif [ "$(echo $LOCAL_ARCH | head -c 6)" = "mips64" ]; then
  TARGET_ARCH="mips64le"
else
  echo "This system's architecture $(LOCAL_ARCH) isn't supported"
  TARGET_ARCH="unsupported"
fi

mkdir -p /etc/kubernetes/ansible

KERNEL_VERSION="5.4.248-1"
if [ "$TARGET_ARCH" = "amd64" ]; then
  if ! [ -e /etc/kubernetes/ansible/kernel-lt-$KERNEL_VERSION.el7.elrepo.x86_64.rpm ]; then
    curl $HTTP_SERVER/kubernetes/kernel/rpm/kernel-lt-$KERNEL_VERSION.el7.elrepo.x86_64.rpm > /etc/kubernetes/ansible/kernel-lt-$KERNEL_VERSION.el7.elrepo.x86_64.rpm
    curl $HTTP_SERVER/kubernetes/kernel/rpm/kernel-lt-headers-$KERNEL_VERSION.el7.elrepo.x86_64.rpm > /etc/kubernetes/ansible/kernel-lt-headers-$KERNEL_VERSION.el7.elrepo.x86_64.rpm
  fi
  rpm -Uvh /etc/kubernetes/ansible/kernel-lt-$KERNEL_VERSION.el7.elrepo.x86_64.rpm
  rpm -Uvh /etc/kubernetes/ansible/kernel-lt-headers-$KERNEL_VERSION.el7.elrepo.x86_64.rpm
  grub2-set-default 0
fi

KERNEL_VERSION="6.1.35-1"
if [ "$TARGET_ARCH" = "arm64" ]; then
  if ! [ -e /etc/kubernetes/ansible/kernel-lt-$KERNEL_VERSION.el9.elrepo.aarch64.rpm ]; then
    curl $HTTP_SERVER/kubernetes/kernel/rpm/kernel-lt-$KERNEL_VERSION.el9.elrepo.aarch64.rpm > /etc/kubernetes/ansible/kernel-lt-$KERNEL_VERSION.el9.elrepo.aarch64.rpm
    curl $HTTP_SERVER/kubernetes/kernel/rpm/kernel-lt-core-$KERNEL_VERSION.el9.elrepo.aarch64.rpm > /etc/kubernetes/ansible/kernel-lt-core-$KERNEL_VERSION.el9.elrepo.aarch64.rpm
    curl $HTTP_SERVER/kubernetes/kernel/rpm/kernel-lt-headers-$KERNEL_VERSION.el9.elrepo.aarch64.rpm > /etc/kubernetes/ansible/kernel-lt-headers-$KERNEL_VERSION.el9.elrepo.aarch64.rpm
  fi
  rpm -Uvh /etc/kubernetes/ansible/kernel-lt-$KERNEL_VERSION.el9.elrepo.aarch64.rpm
  rpm -Uvh /etc/kubernetes/ansible/kernel-lt-core-$KERNEL_VERSION.el9.elrepo.aarch64.rpm
  rpm -Uvh /etc/kubernetes/ansible/kernel-lt-headers-$KERNEL_VERSION.el9.elrepo.aarch64.rpm
  grub2-set-default 0
fi