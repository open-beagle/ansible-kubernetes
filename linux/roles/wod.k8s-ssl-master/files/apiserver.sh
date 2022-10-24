#!/bin/bash

set -ex

cd /etc/kubernetes/ssl
 
if ! [ -e /etc/kubernetes/ssl/apiserver.key ]; then
  openssl genrsa -out apiserver.key 2048
fi

if ! [ -e /etc/kubernetes/ssl/apiserver.crt ]; then
  openssl req -new -key apiserver.key -out apiserver.csr -subj "/CN=apiserver/C=CN/ST=BeiJing/L=Beijing/O=bd-apaas.com/OU=System" -config apiserver.cnf
  openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out apiserver.crt -days 36500 -extensions v3_req -extfile apiserver.cnf
fi

if ! [ -e /etc/kubernetes/ssl/apiserver.pub ]; then
  openssl rsa -in apiserver.key -pubout > apiserver.pub
fi
