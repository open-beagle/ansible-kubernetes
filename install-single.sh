#!/bin/bash

# 单机模式安装：适用于直接暴露在公网的单台物理服务器，在该服务器上以root执行
# - 自动生成单机 inventory，ansible 通过 127.0.0.1 连接本机
# - 使用临时 SSH 密钥连接本机，安装结束后自动移除
# - 证书仓库保存在 /etc/kubernetes/ansible/ssl，首次安装自动生成CA
# - etcd、registry 仅监听 127.0.0.1，公网网卡拦截 6443 等集群内部端口

export PATH=/opt/bin:$PATH

set -ex

# K8S版本
K8S_VERSION="${K8S_VERSION:-v1.32.10}"
# K8S发布版本
K8S_RELEASE="${K8S_VERSION#v}"
K8S_RELEASE="${K8S_RELEASE%.*}"
# ANSIBLE-K8S版本
ANSIBLE_K8S_VERSION="${ANSIBLE_K8S_VERSION:-latest}"
# 节点名称，k8s要求小写
NODE_NAME="${NODE_NAME:-$(hostname -s | tr 'A-Z' 'a-z')}"
# 本机SSH端口
SSH_PORT="${SSH_PORT:-$(sshd -T 2>/dev/null | awk '$1 == "port" {print $2; exit}')}"
SSH_PORT="${SSH_PORT:-22}"

if ! [ -x "$(command -v docker)" ]; then
  mkdir -p /opt/docker
  curl -sfL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-docker.sh >/opt/docker/ansible-docker.sh
  bash /opt/docker/ansible-docker.sh
fi

mkdir -p /etc/kubernetes/ansible/ssl
chmod 0700 /etc/kubernetes/ansible/ssl

cat >/etc/kubernetes/ansible/ansible-kubernetes-single.ini <<-EOF
[master]
${NODE_NAME} ansible_ssh_host=127.0.0.1 ansible_ssh_port=${SSH_PORT} ansible_ssh_user=root

[node]
EOF

if ! [ -e /etc/kubernetes/ansible/ansible-kubernetes.yml ]; then
  cat >/etc/kubernetes/ansible/ansible-kubernetes.yml <<-EOF
REGISTRY_LOCAL: "registry.cn-qingdao.aliyuncs.com/wod"
K8S_VERSION: "${K8S_VERSION}"
EOF
fi

# 持久化单机模式，后续执行 4.update.yml 时 etcd、registry 仍仅监听 127.0.0.1
if ! (grep -q "^K8S_SINGLE:" /etc/kubernetes/ansible/ansible-kubernetes.yml); then
  printf '\nK8S_SINGLE: true\n' >>/etc/kubernetes/ansible/ansible-kubernetes.yml
fi
sed -i --expression "s?^K8S_SINGLE:.*?K8S_SINGLE: true?" /etc/kubernetes/ansible/ansible-kubernetes.yml

# 公网服务器不保留通用的 ansible 安装公钥，以及上次异常中断残留的临时公钥
if [ -e /root/.ssh/authorized_keys ]; then
  sed -i '/ansible@bd-apaas\.com/d; / ansible@beagle\.io$/d' /root/.ssh/authorized_keys
fi

# 临时SSH密钥，安装结束（含失败）后移除
SSH_KEY_DIR="$(mktemp -d)"
SSH_KEY_COMMENT="ansible@beagle.io"
cleanup() {
  sed -i '/ ansible@beagle\.io$/d' /root/.ssh/authorized_keys
  rm -rf "${SSH_KEY_DIR}"
}
trap cleanup EXIT

ssh-keygen -q -t ed25519 -N '' -C "${SSH_KEY_COMMENT}" -f "${SSH_KEY_DIR}/id_ed25519"
mkdir -p /root/.ssh
chmod 0700 /root/.ssh
cat "${SSH_KEY_DIR}/id_ed25519.pub" >>/root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys

docker run \
  -t \
  --rm \
  --network host \
  -v /etc/kubernetes/ansible/ansible-kubernetes-single.ini:/etc/ansible/hosts \
  -v /etc/kubernetes/ansible/ansible-kubernetes.yml:/etc/ansible/linux/beagle_vars/ansible-kubernetes.yml \
  -v /etc/kubernetes/ansible/ssl:/etc/ansible/linux/ssl \
  -v "${SSH_KEY_DIR}":/etc/ansible/beagle_ssh:ro \
  -w /etc/ansible/linux \
  registry.cn-qingdao.aliyuncs.com/wod/ansible-kubernetes:${ANSIBLE_K8S_VERSION} \
  ansible-playbook 1.install-single.yml \
  --private-key /etc/ansible/beagle_ssh/id_ed25519 \
  --extra-vars "@./beagle_vars/ansible-kubernetes.yml" \
  --extra-vars "@./vars/${K8S_RELEASE}.yml"
