#!/bin/bash 

set -e  

mkdir -p /etc/kubernetes/ssl/etcd

if ! [ -e /etc/kubernetes/ssl/etcd/.beagle_etcd_version_{{ BEAGLE_ETCD_VERSION }} ]; then
  touch /etc/kubernetes/ssl/etcd/.beagle_etcd_version_{{ BEAGLE_ETCD_VERSION }}
  rm -rf /etc/kubernetes/ssl/etcd/server.crt /etc/kubernetes/ssl/etcd/server.csr
  rm -rf /etc/kubernetes/ssl/etcd/peer.crt /etc/kubernetes/ssl/etcd/server.csr
fi
 
if ! [ -e /etc/kubernetes/ssl/etcd/server.key ]; then
  openssl genrsa -out /etc/kubernetes/ssl/etcd/server.key 2048
fi  

if ! [ -e /etc/kubernetes/ssl/etcd/server.crt ]; then
  openssl req -new -key /etc/kubernetes/ssl/etcd/server.key \
              -out /etc/kubernetes/ssl/etcd/server.csr \
              -subj "/CN=server/C=CN/ST=BeiJing/L=Beijing/O=system:etcd:masters/OU=System" \
              -config /etc/kubernetes/ssl/etcd/server.cnf

  openssl x509 -req -in /etc/kubernetes/ssl/etcd/server.csr \
               -CA /etc/kubernetes/ssl/etcd/ca.crt \
               -CAkey /etc/kubernetes/ssl/etcd/ca.key \
               -CAcreateserial -out /etc/kubernetes/ssl/etcd/server.crt \
               -days 36500 -extensions v3_req \
               -extfile /etc/kubernetes/ssl/etcd/server.cnf
fi

if ! [ -e /etc/kubernetes/ssl/etcd/peer.key ]; then
  openssl genrsa -out /etc/kubernetes/ssl/etcd/peer.key 2048
fi  

if ! [ -e /etc/kubernetes/ssl/etcd/peer.crt ]; then
  openssl req -new -key /etc/kubernetes/ssl/etcd/peer.key \
              -out /etc/kubernetes/ssl/etcd/peer.csr \
              -subj "/CN=peer/C=CN/ST=BeiJing/L=Beijing/O=system:etcd:masters/OU=System" \
              -config /etc/kubernetes/ssl/etcd/server.cnf

  openssl x509 -req -in /etc/kubernetes/ssl/etcd/peer.csr \
               -CA /etc/kubernetes/ssl/etcd/ca.crt \
               -CAkey /etc/kubernetes/ssl/etcd/ca.key \
               -CAcreateserial -out /etc/kubernetes/ssl/etcd/peer.crt \
               -days 36500 -extensions v3_req \
               -extfile /etc/kubernetes/ssl/etcd/server.cnf
fi

if ! [ -e /etc/kubernetes/ssl/etcd/apiserver-etcd-client.key ]; then
  openssl genrsa -out /etc/kubernetes/ssl/etcd/apiserver-etcd-client.key 2048
fi  

if ! [ -e /etc/kubernetes/ssl/etcd/apiserver-etcd-client.crt ]; then
  openssl req -new -key /etc/kubernetes/ssl/etcd/apiserver-etcd-client.key \
              -out /etc/kubernetes/ssl/etcd/apiserver-etcd-client.csr \
              -subj "/CN=apiserver/C=CN/ST=BeiJing/L=Beijing/O=system:etcd:masters/OU=System" 
              
  openssl x509 -req -in /etc/kubernetes/ssl/etcd/apiserver-etcd-client.csr \
              -CA /etc/kubernetes/ssl/etcd/ca.crt \
              -CAkey /etc/kubernetes/ssl/etcd/ca.key \
              -CAcreateserial -out /etc/kubernetes/ssl/etcd/apiserver-etcd-client.crt \
              -days 36500 -extensions v3_req
fi
