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
elif [ "$LOCAL_ARCH" = "ppc64le" ]; then
  TARGET_ARCH="ppc64le"
elif [ "$LOCAL_ARCH" = "mips64" ]; then
  TARGET_ARCH="mips64le"
else
  echo "This system's architecture $(LOCAL_ARCH) isn't supported"
  TARGET_ARCH="unsupported"
fi

mkdir -p /etc/kubernetes/downloads

LINUX_MODULES="linux-modules-5.10.2-051002-generic_5.10.2-051002.202012210832_amd64"
LINUX_HEADERS="linux-headers-5.10.2-051002_5.10.2-051002.202012210832_all"
LINUX_HEADERS_GENERIC="linux-headers-5.10.2-051002-generic_5.10.2-051002.202012210832_amd64"
LINUX_IMAGE="linux-image-unsigned-5.10.2-051002-generic_5.10.2-051002.202012210832_amd64"
if [ "$TARGET_ARCH" = "amd64" ]; then
  if ! [ "$LOCAL_KERNEL" = "5.10" ]; then
  curl $HTTP_SERVER/kernel/deb/v5.10.2/$TARGET_ARCH/$LINUX_MODULES.deb > /etc/kubernetes/downloads/$LINUX_MODULES.deb
  curl $HTTP_SERVER/kernel/deb/v5.10.2/$TARGET_ARCH/$LINUX_HEADERS.deb > /etc/kubernetes/downloads/$LINUX_HEADERS.deb
  curl $HTTP_SERVER/kernel/deb/v5.10.2/$TARGET_ARCH/$LINUX_HEADERS_GENERIC.deb > /etc/kubernetes/downloads/$LINUX_HEADERS_GENERIC.deb
  curl $HTTP_SERVER/kernel/deb/v5.10.2/$TARGET_ARCH/$LINUX_IMAGE.deb > /etc/kubernetes/downloads/$LINUX_IMAGE.deb

  dpkg -i /etc/kubernetes/downloads/$LINUX_MODULES.deb
  dpkg -i /etc/kubernetes/downloads/$LINUX_HEADERS.deb
  dpkg -i /etc/kubernetes/downloads/$LINUX_HEADERS_GENERIC.deb
  dpkg -i /etc/kubernetes/downloads/$LINUX_IMAGE.deb
  
  shutdown -r 0
  exit 1
  fi
fi

LINUX_MODULES="linux-modules-5.10.2-051002-generic_5.10.2-051002.202012210832_arm64"
LINUX_HEADERS="linux-headers-5.10.2-051002-generic_5.10.2-051002.202012210832_arm64"
LINUX_IMAGE="linux-image-5.10.2-051002-generic_5.10.2-051002.202012210832_arm64"
if [ "$TARGET_ARCH" = "arm64" ]; then
  if ! [ "$LOCAL_KERNEL" = "5.10" ]; then
  curl $HTTP_SERVER/kernel/deb/v5.10.2/$TARGET_ARCH/$LINUX_MODULES.deb > /etc/kubernetes/downloads/$LINUX_MODULES.deb
  curl $HTTP_SERVER/kernel/deb/v5.10.2/$TARGET_ARCH/$LINUX_HEADERS.deb > /etc/kubernetes/downloads/$LINUX_HEADERS.deb
  curl $HTTP_SERVER/kernel/deb/v5.10.2/$TARGET_ARCH/$LINUX_IMAGE.deb > /etc/kubernetes/downloads/$LINUX_IMAGE.deb

  dpkg -i /etc/kubernetes/downloads/$LINUX_MODULES.deb
  dpkg -i /etc/kubernetes/downloads/$LINUX_HEADERS.deb
  dpkg -i /etc/kubernetes/downloads/$LINUX_IMAGE.deb

  shutdown -r 0
  exit 1
  fi
fi
