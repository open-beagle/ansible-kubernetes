#!/bin/bash 

set -e  

HTTP_SERVER="${HTTP_SERVER:-https://cache.wodcloud.com/kubernetes}" 
KERNEL_VERSION="${KERNEL_VERSION:-5.4.219-0504219}"
KERNEL_RELEASE="${KERNEL_RELEASE:-202210171633}"

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

LINUX_HEADERS_ALL="linux-headers-${KERNEL_VERSION}_${KERNEL_VERSION}.${KERNEL_RELEASE}_all"
LINUX_HEADERS="linux-headers-${KERNEL_VERSION}-generic_${KERNEL_VERSION}.${KERNEL_RELEASE}_${TARGET_ARCH}"
LINUX_IMAGE="linux-image-unsigned-${KERNEL_VERSION}-generic_${KERNEL_VERSION}.${KERNEL_RELEASE}_${TARGET_ARCH}"
LINUX_MODULES="linux-modules-${KERNEL_VERSION}-generic_${KERNEL_VERSION}.${KERNEL_RELEASE}_${TARGET_ARCH}"
if [ "$TARGET_ARCH" = "amd64" ]; then
  if ! [ "$LOCAL_KERNEL" = "5.4" ]; then
    if ! [ -e /etc/kubernetes/ansible/$LINUX_HEADERS_ALL.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_HEADERS_ALL.deb > /etc/kubernetes/ansible/$LINUX_HEADERS_ALL.deb
    fi
    if ! [ -e /etc/kubernetes/ansible/$LINUX_HEADERS.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_HEADERS.deb > /etc/kubernetes/ansible/$LINUX_HEADERS.deb
    fi
    if ! [ -e /etc/kubernetes/ansible/$LINUX_IMAGE.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_IMAGE.deb > /etc/kubernetes/ansible/$LINUX_IMAGE.deb
    fi
    if ! [ -e /etc/kubernetes/ansible/$LINUX_MODULES.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_MODULES.deb > /etc/kubernetes/ansible/$LINUX_MODULES.deb
    fi

    dpkg -i /etc/kubernetes/ansible/$LINUX_MODULES.deb
    dpkg -i /etc/kubernetes/ansible/$LINUX_HEADERS_ALL.deb
    dpkg -i /etc/kubernetes/ansible/$LINUX_HEADERS.deb
    dpkg -i /etc/kubernetes/ansible/$LINUX_IMAGE.deb

  fi
fi

if [ "$TARGET_ARCH" = "arm64" ]; then
  if ! [ "$LOCAL_KERNEL" = "5.4" ]; then
    if ! [ -e /etc/kubernetes/ansible/$LINUX_HEADERS.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_HEADERS.deb > /etc/kubernetes/ansible/$LINUX_HEADERS.deb
    fi
    if ! [ -e /etc/kubernetes/ansible/$LINUX_IMAGE.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_IMAGE.deb > /etc/kubernetes/ansible/$LINUX_IMAGE.deb
    fi
    if ! [ -e /etc/kubernetes/ansible/$LINUX_MODULES.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_MODULES.deb > /etc/kubernetes/ansible/$LINUX_MODULES.deb
    fi

    dpkg -i /etc/kubernetes/ansible/$LINUX_MODULES.deb
    dpkg -i /etc/kubernetes/ansible/$LINUX_HEADERS.deb
    dpkg -i /etc/kubernetes/ansible/$LINUX_IMAGE.deb

  fi
fi
