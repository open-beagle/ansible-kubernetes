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

KERNEL_VERSION="5.4.246-0504246-generic_5.4.246-0504246.202306090538"
if [ "$TARGET_ARCH" = "amd64" ]; then
  if ! [ -e /etc/kubernetes/ansible/linux-headers-${KERNEL_VERSION}_amd64.deb ]; then
    curl $HTTP_SERVER/kubernetes/kernel/deb/linux-headers-${KERNEL_VERSION}_amd64.deb > /etc/kubernetes/ansible/linux-headers-${KERNEL_VERSION}_amd64.deb
  fi
  if ! [ -e /etc/kubernetes/ansible/linux-modules-${KERNEL_VERSION}_amd64.deb ]; then
    curl $HTTP_SERVER/kubernetes/kernel/deb/linux-modules-${KERNEL_VERSION}_amd64.deb > /etc/kubernetes/linux-modules-${KERNEL_VERSION}_amd64.deb
  fi
  if ! [ -e /etc/kubernetes/ansible/linux-image-unsigned-${KERNEL_VERSION}_amd64.deb ]; then
    curl $HTTP_SERVER/kubernetes/kernel/deb/linux-image-unsigned-${KERNEL_VERSION}_amd64.deb > /etc/kubernetes/ansible/linux-image-unsigned-${KERNEL_VERSION}_amd64.deb
  fi

  dpkg -i /etc/kubernetes/ansible/linux-modules-${KERNEL_VERSION}_amd64.deb
  dpkg -i /etc/kubernetes/ansible/linux-headers-${KERNEL_VERSION}_amd64.deb
  dpkg -i /etc/kubernetes/ansible/linux-image-unsigned-${KERNEL_VERSION}_amd64.deb
fi

KERNEL_VERSION="5.4.246-0504246-generic_5.4.246-0504246.202306090538"
if [ "$TARGET_ARCH" = "arm64" ]; then
  if ! [ -e /etc/kubernetes/ansible/linux-headers-${KERNEL_VERSION}_arm64.deb ]; then
    curl $HTTP_SERVER/kubernetes/kernel/deb/linux-headers-${KERNEL_VERSION}_arm64.deb > /etc/kubernetes/ansible/linux-headers-${KERNEL_VERSION}_arm64.deb
  fi
  if ! [ -e /etc/kubernetes/ansible/linux-modules-${KERNEL_VERSION}_arm64.deb ]; then
    curl $HTTP_SERVER/kubernetes/kernel/deb/linux-modules-${KERNEL_VERSION}_arm64.deb > /etc/kubernetes/linux-modules-${KERNEL_VERSION}_arm64.deb
  fi
  if ! [ -e /etc/kubernetes/ansible/linux-image-unsigned-${KERNEL_VERSION}_arm64.deb ]; then
    curl $HTTP_SERVER/kubernetes/kernel/deb/linux-image-unsigned-${KERNEL_VERSION}_arm64.deb > /etc/kubernetes/ansible/linux-image-unsigned-${KERNEL_VERSION}_arm64.deb
  fi

  dpkg -i /etc/kubernetes/ansible/linux-modules-${KERNEL_VERSION}_arm64.deb
  dpkg -i /etc/kubernetes/ansible/linux-headers-${KERNEL_VERSION}_arm64.deb
  dpkg -i /etc/kubernetes/ansible/linux-image-unsigned-${KERNEL_VERSION}_arm64.deb
fi
