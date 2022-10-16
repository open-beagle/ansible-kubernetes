#!/bin/bash 

set -e  

REGISTRY_LOCAL="{{ REGISTRY_LOCAL }}"
REGISTRY_REPO="{{ K8S_IMAGES['KUBECTL']['NAME'] }}"
REGISTRY_VERSION="{{ K8S_IMAGES['KUBECTL']['VERSION'] }}{{ "-%s" | format(K8S_ARCH) | replace("-amd64", "") }}"

mkdir -p /etc/kubernetes/downloads
mkdir -p /opt/bin

LOCAL_ARCH=$(uname -m)

if ! [ -e /etc/kubernetes/downloads/kubectl-linux-$REGISTRY_VERSION ]; then
  docker run -v /etc/kubernetes/downloads:/data/output \
    --rm --entrypoint=sh \
    $REGISTRY_LOCAL/$REGISTRY_REPO:$REGISTRY_VERSION \
    -c 'cp /usr/local/bin/kubectl /data/output/kubectl'
  mv /etc/kubernetes/downloads/kubectl /etc/kubernetes/downloads/kubectl-linux-$REGISTRY_VERSION
  chmod +x /etc/kubernetes/downloads/kubectl-linux-$REGISTRY_VERSION
  rm -rf /opt/bin/kubectl
  ln -s /etc/kubernetes/downloads/kubectl-linux-$REGISTRY_VERSION /opt/bin/kubectl      
fi

/opt/bin/kubectl config set-cluster kubernetes --server=https://{{ K8S_MASTER_HOST }}:{{ K8S_MASTER_PORT }} --certificate-authority=/etc/kubernetes/ssl/ca.crt
/opt/bin/kubectl config set-credentials default --client-certificate=/etc/kubernetes/ssl/admin.crt --client-key=/etc/kubernetes/ssl/admin.key
/opt/bin/kubectl config set-context kubernetes --cluster=kubernetes --user=default
/opt/bin/kubectl config use-context kubernetes  

if ! [ -x "$(command -v kubectl)" ]; then
  ln -s /opt/bin/kubectl /usr/bin/kubectl
fi
