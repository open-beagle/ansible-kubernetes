# 安装历史版本 k8s

请参考下面的 1.24 安装步骤。

## 1.24

k8s 在 1.24 首次取消了对 docker 的支持。

```bash
# 安装docker
# 略

# 准备安装目录
mkdir -p /etc/kubernetes/ansible

# 准备ansible-kubernetes镜像
curl -sL https://cache.wodcloud.com/kubernetes/k8s/ansible/ansible-kubernetes-latest-amd64.tgz >/etc/kubernetes/ansible/ansible-kubernetes-latest-amd64.tgz && \

# 准备k8s-1.24离线镜像
curl -sL https://cache.wodcloud.com/kubernetes/k8s/ansible/ansible-kubernetes-images-v1.24.17-amd64.tgz >/etc/kubernetes/ansible/ansible-kubernetes-images-v1.24.17-amd64.tgz && \

# 准备hosts文件
cat > /etc/kubernetes/ansible/ansible-kubernetes.ini <<-EOF
[master]
beagle-01 ansible_ssh_host=192.168.1.201 ansible_ssh_port=22 ansible_ssh_user=root

[node]
beagle-02 ansible_ssh_host=192.168.1.202 ansible_ssh_port=22 ansible_ssh_user=root
beagle-03 ansible_ssh_host=192.168.1.203 ansible_ssh_port=22 ansible_ssh_user=root
EOF

# 准备ansible-kubernetes配置文件
cat >/etc/kubernetes/ansible/ansible-kubernetes.yml <<-EOF
K8S_VERSION: "v1.24.17"
EOF

# 加载ansible-kubernetes镜像
docker load -i /etc/kubernetes/ansible/ansible-kubernetes-latest-amd64.tgz

# 运行ansible-kubernetes容器
# 安装k8s
docker run \
  -t \
  --rm \
  -v /etc/kubernetes/ansible/ansible-kubernetes.ini:/etc/ansible/hosts \
  -v /etc/kubernetes/ansible/ansible-kubernetes.yml:/etc/ansible/linux/beagle_vars/ansible-kubernetes.yml \
  -v /etc/kubernetes/ansible/ansible-kubernetes-images-v1.24.17-amd64:/etc/ansible/linux/roles/wod.registry/files/images/ansible-kubernetes-images-v1.24.17-amd64.tgz \
  -w /etc/ansible/linux \
  registry.cn-qingdao.aliyuncs.com/wod/ansible-kubernetes:latest-amd64 \
  ansible-playbook 1.install.yml \
  --extra-vars "@./beagle_vars/ansible-kubernetes.yml" \
  --extra-vars "@./vars/1.24.yml"
```
