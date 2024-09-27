#!/bin/bash

set -e

cd /etc/kubernetes/ssl

if ! [ -e /etc/kubernetes/ssl/admin.key ]; then
  openssl genrsa -out admin.key 2048
fi

if ! [ -e /etc/kubernetes/ssl/admin.crt ]; then
  openssl req -new -key admin.key -out admin.csr -subj "/CN=kubernetes-admin/C=CN/ST=BeiJing/L=Beijing/O=system:masters/OU=System"
  openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out admin.crt -days 36500 -extensions v3_req
fi
