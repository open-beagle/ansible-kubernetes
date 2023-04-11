#!/bin/bash 

set -e  

HTTP_SERVER="${HTTP_SERVER:-https://cache.wodcloud.com/kubernetes}" 

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

LINUX_KERNEL="kernel-lt-5.4.219-1.el7.elrepo.x86_64"
if [ "$TARGET_ARCH" = "amd64" ]; then
  if ! [ "$LOCAL_KERNEL" = "5.4" ]; then
    if ! [ -e /etc/kubernetes/ansible/$LINUX_KERNEL.rpm ]; then
      curl $HTTP_SERVER/kernel/rpm/v5.4/$TARGET_ARCH/$LINUX_KERNEL.rpm > /etc/kubernetes/downloads/$LINUX_KERNEL.rpm
    fi
    rpm -Uvh /etc/kubernetes/ansible/$LINUX_KERNEL.rpm
    grub2-set-default 0
  fi
fi
