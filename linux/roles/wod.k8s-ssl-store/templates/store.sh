#!/bin/bash

set -e

# 仅生成证书仓库缺失、且本机也不存在的文件，已存在的文件保持不变

cd /etc/kubernetes/ssl

gen_ca() {
  local dir="$1"
  local cn="$2"

  if [ -e ${dir}/ca.key ]; then
    return
  fi

  cat >${dir}/ca.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
prompt = no
[req_distinguished_name]
CN = ${cn}
[v3_ca]
basicConstraints = critical, CA:TRUE
keyUsage = critical, digitalSignature, keyEncipherment, keyCertSign, cRLSign
subjectKeyIdentifier = hash
EOF

  openssl genrsa -out ${dir}/ca.key 4096
  chmod 0600 ${dir}/ca.key
  openssl req -x509 -new -nodes -sha256 -days 36500 \
    -key ${dir}/ca.key \
    -config ${dir}/ca.cnf \
    -out ${dir}/ca.crt
}

{% if 'ca.key' in K8S_SSL_STORE_MISSING %}
gen_ca /etc/kubernetes/ssl kubernetes
{% endif %}

{% if 'etcd/ca.key' in K8S_SSL_STORE_MISSING %}
gen_ca /etc/kubernetes/ssl/etcd etcd
{% endif %}

{% if 'apiserver.key' in K8S_SSL_STORE_MISSING %}
if ! [ -e /etc/kubernetes/ssl/apiserver.key ]; then
  openssl genrsa -out /etc/kubernetes/ssl/apiserver.key 2048
  chmod 0600 /etc/kubernetes/ssl/apiserver.key
fi
{% endif %}

{% if 'admin.token' in K8S_SSL_STORE_MISSING %}
if ! [ -e /etc/kubernetes/ssl/admin.token ]; then
  if [ -e /etc/kubernetes/ssl/token.csv ]; then
    # 老集群沿用已有的Token
    cut -d, -f1 /etc/kubernetes/ssl/token.csv | head -n 1 >/etc/kubernetes/ssl/admin.token
  else
{% if K8S_ADMIN_TOKEN is defined %}
    echo "{{ K8S_ADMIN_TOKEN }}" >/etc/kubernetes/ssl/admin.token
{% else %}
    openssl rand -hex 32 >/etc/kubernetes/ssl/admin.token
{% endif %}
  fi
  chmod 0600 /etc/kubernetes/ssl/admin.token
fi
{% endif %}
