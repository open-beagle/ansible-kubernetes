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

mkdir -p /etc/kubernetes/ansible

LINUX_MODULES="linux-modules-5.4.219-0504219-generic_5.4.219-0504219.202210171633_amd64"
LINUX_HEADERS="linux-headers-5.4.219-0504219_5.4.219-0504219.202210171633_all"
LINUX_HEADERS_GENERIC="linux-headers-5.4.219-0504219-generic_5.4.219-0504219.202210171633_amd64"
LINUX_IMAGE="linux-image-unsigned-5.4.219-0504219-generic_5.4.219-0504219.202210171633_amd64"
if [ "$TARGET_ARCH" = "amd64" ]; then
  if ! [ "$LOCAL_KERNEL" = "5.4" ]; then
    if ! [ -e /etc/kubernetes/ansible/$LINUX_MODULES.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_MODULES.deb > /etc/kubernetes/ansible/$LINUX_MODULES.deb
    fi
    if ! [ -e /etc/kubernetes/ansible/$LINUX_HEADERS.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_HEADERS.deb > /etc/kubernetes/ansible/$LINUX_HEADERS.deb
    fi
    if ! [ -e /etc/kubernetes/ansible/$LINUX_HEADERS_GENERIC.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_HEADERS_GENERIC.deb > /etc/kubernetes/ansible/$LINUX_HEADERS_GENERIC.deb
    fi
    if ! [ -e /etc/kubernetes/ansible/$LINUX_IMAGE.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_IMAGE.deb > /etc/kubernetes/ansible/$LINUX_IMAGE.deb
    fi
  fi

  dpkg -i /etc/kubernetes/ansible/$LINUX_MODULES.deb
  dpkg -i /etc/kubernetes/ansible/$LINUX_HEADERS.deb
  dpkg -i /etc/kubernetes/ansible/$LINUX_HEADERS_GENERIC.deb
  dpkg -i /etc/kubernetes/ansible/$LINUX_IMAGE.deb
  
  shutdown -r 0
  exit 0
  fi
fi

LINUX_MODULES="linux-modules-5.4.219-0504219-generic_5.4.219-0504219.202210171633_arm64"
LINUX_HEADERS="linux-image-unsigned-5.4.219-0504219-generic_5.4.219-0504219.202210171633_arm64"
LINUX_IMAGE="linux-headers-5.4.219-0504219-generic_5.4.219-0504219.202210171633_arm64"
if [ "$TARGET_ARCH" = "arm64" ]; then
  if ! [ "$LOCAL_KERNEL" = "5.4" ]; then
    if ! [ -e /etc/kubernetes/ansible/$LINUX_MODULES.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_MODULES.deb > /etc/kubernetes/ansible/$LINUX_MODULES.deb
    fi
    if ! [ -e /etc/kubernetes/ansible/$LINUX_HEADERS.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_HEADERS.deb > /etc/kubernetes/ansible/$LINUX_HEADERS.deb
    fi
    if ! [ -e /etc/kubernetes/ansible/$LINUX_IMAGE.deb ]; then
      curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_IMAGE.deb > /etc/kubernetes/ansible/$LINUX_IMAGE.deb
    fi

  dpkg -i /etc/kubernetes/ansible/$LINUX_MODULES.deb
  dpkg -i /etc/kubernetes/ansible/$LINUX_HEADERS.deb
  dpkg -i /etc/kubernetes/ansible/$LINUX_IMAGE.deb

  shutdown -r 0
  exit 0
  fi
fi
