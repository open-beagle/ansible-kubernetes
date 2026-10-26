#!/bin/bash
set -e

# 本机生成私钥与CSR，证书由 master[0] 签发，私钥不离开本机

if ! [ -e /etc/kubernetes/ssl/kubelet.key ]; then
  openssl genrsa -out /etc/kubernetes/ssl/kubelet.key 2048
  chmod 0600 /etc/kubernetes/ssl/kubelet.key
fi

if ! [ -e /etc/kubernetes/ssl/kubelet.crt ]; then
  openssl req -new -key /etc/kubernetes/ssl/kubelet.key -out /etc/kubernetes/ssl/kubelet.csr \
          -subj "/CN=system:node:{{ inventory_hostname }}/C=CN/ST=BeiJing/L=Beijing/O=system:nodes/OU=System" -config /etc/kubernetes/ssl/kubelet.cnf
fi
