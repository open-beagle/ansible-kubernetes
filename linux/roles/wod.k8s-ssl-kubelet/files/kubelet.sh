#!/bin/bash  
set -e 

if ! [ -e /etc/kubernetes/ssl/kubelet.key ]; then
  openssl genrsa -out /etc/kubernetes/ssl/kubelet.key 2048
fi

if ! [ -e /etc/kubernetes/ssl/kubelet.crt ]; then
  openssl req -new -key /etc/kubernetes/ssl/kubelet.key -out /etc/kubernetes/ssl/kubelet.csr \
          -subj "/CN=kubelet/C=CN/ST=BeiJing/L=Beijing/O=system:masters/OU=System" -config /etc/kubernetes/ssl/kubelet.cnf
  openssl x509 -req -in /etc/kubernetes/ssl/kubelet.csr -CA /etc/kubernetes/ssl/ca.crt \
          -CAkey /etc/kubernetes/ssl/ca.key -CAcreateserial -out /etc/kubernetes/ssl/kubelet.crt \
          -days 36500 -extensions v3_req -extfile /etc/kubernetes/ssl/kubelet.cnf
fi
