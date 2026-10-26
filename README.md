# QuickStart Kubernetes Cluster

## 简介

- 快速搭建一个 Kubernetes 集群
- 搭建过程离线，无需访问互联网
- 一行命令，使用 ansible，全程自动化

### 限制条件

- Linux Kernel >= 4.19 , 推荐 Ubuntu 24.04

### 核心组件

- 容器引擎: containerd 2.1
- 容器平台: kubernetes v1.32
- 数据库: etcd v3.5
- 网络组件: cilium v1.18
- 扩展组件: coredns 1.11

## 准备 hosts 文件

请参考[Ansible.md](./docs/Ansible.md)

```bash
# 单主节点集群
mkdir -p /etc/kubernetes/ansible && \
rm -rf /etc/kubernetes/ansible/ansible-kubernetes.ini && \
cat > /etc/kubernetes/ansible/ansible-kubernetes.ini <<-EOF
[master]
beagle-01 ansible_ssh_host=192.168.1.201 ansible_ssh_port=22 ansible_ssh_user=root

[node]
beagle-02 ansible_ssh_host=192.168.1.202 ansible_ssh_port=22 ansible_ssh_user=root
beagle-03 ansible_ssh_host=192.168.1.203 ansible_ssh_port=22 ansible_ssh_user=root
EOF

# 高可用集群
mkdir -p /etc/kubernetes/ansible && \
rm -rf /etc/kubernetes/ansible/ansible-kubernetes.ini && \
cat > /etc/kubernetes/ansible/ansible-kubernetes.ini <<-EOF
[master]
beagle-01 ansible_ssh_host=192.168.1.201 ansible_ssh_port=22 ansible_ssh_user=root
beagle-02 ansible_ssh_host=192.168.1.202 ansible_ssh_port=22 ansible_ssh_user=root
beagle-03 ansible_ssh_host=192.168.1.203 ansible_ssh_port=22 ansible_ssh_user=root

[node]
beagle-04 ansible_ssh_host=192.168.1.204 ansible_ssh_port=22 ansible_ssh_user=root
EOF
```

配置说明：

- [master] , k8s 控制平面-管理节点配置；
- [node] , k8s 计算节点配置；

## 在线安装 kubernetes 集群

配置文件请参考[all.yml](./linux/group_vars/all.yml)

```bash
# 安装docker
mkdir -p /opt/docker && \
curl -sfL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-docker.sh > /opt/docker/ansible-docker.sh && \
bash /opt/docker/ansible-docker.sh

# 安装k8s
mkdir -p /etc/kubernetes/ansible && \
curl -sfL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-kubernetes.sh > /etc/kubernetes/ansible/ansible-kubernetes.sh && \
bash /etc/kubernetes/ansible/ansible-kubernetes.sh
```

## 单机安装 kubernetes（公网服务器）

适用于直接暴露在互联网的单台物理服务器，在该服务器上以 root 执行，无需准备 hosts 文件

```bash
mkdir -p /etc/kubernetes/ansible && \
curl -sfL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-kubernetes-single.sh > /etc/kubernetes/ansible/ansible-kubernetes-single.sh && \
bash /etc/kubernetes/ansible/ansible-kubernetes-single.sh
```

与集群安装的区别：

- etcd、registry 仅监听 `127.0.0.1`
- `k8s-guard` 服务在公网网卡上拦截 `6443`、`2379-2381`、`6444`、`10250` 等集群内部端口，并在 `ingress` 钩子丢弃直连 Pod/Service/Docker 内网段（`10.2.0.0/16`、`10.3.0.0/16`、`172.17.0.0/16`）的外部伪造路由流量；管理 IP 可通过 `K8S_GUARD_ALLOW_CIDRS` 放行，或使用 `ssh -L 6443:127.0.0.1:6443` 访问
- 使用临时 SSH 密钥连接本机，安装结束后自动移除，并清理 `ansible@bd-apaas.com` 公钥
- 单机模式安装的集群不支持再通过 `3.install-node.yml` 扩容
- SSH、80、443 及业务端口不做处理，请在外部防火墙（如 Hetzner Robot Firewall）配置白名单

## 证书仓库

首次安装时在 `master[0]` 上随机生成集群 CA、etcd CA、ServiceAccount 私钥与管理员 Token，保存至 `/etc/kubernetes/ansible/ssl`，后续扩容、升级从该目录分发。已安装的老集群会从 `master[0]` 回收原有证书，无需额外操作。

如需使用自备 CA，安装前将 `ca.crt`、`ca.key`、`etcd/ca.crt`、`etcd/ca.key` 放入 `/etc/kubernetes/ansible/ssl`。

## 离线安装 kubernetes 集群

```bash
# 安装docker
# HTTP_SERVER=https://cache.ali.wodcloud.com
# TARGET_ARCH=amd64;arm64;
mkdir -p /opt/docker && \
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-docker-28.3.2-amd64.tgz > /opt/docker/ansible-docker-28.3.2-amd64.tgz && \
curl -sfL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-docker.sh > /opt/docker/ansible-docker.sh && \
export DOCKER_VERSION=28.3.2 && \
bash /opt/docker/ansible-docker.sh

# 开始安装k8s
mkdir -p /etc/kubernetes/ansible && \
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-kubernetes-images-v1.32.10-amd64.tgz >/etc/kubernetes/ansible/ansible-kubernetes-images-v1.32.10-amd64.tgz && \
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-kubernetes-v1.32.10-amd64.tgz >/etc/kubernetes/ansible/ansible-kubernetes-v1.32.10-amd64.tgz && \
curl -sfL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-kubernetes-v1.32.10.sh > /etc/kubernetes/ansible/ansible-kubernetes-v1.32.10.sh && \
export K8S_VERSION=v1.32.10 && \
bash /etc/kubernetes/ansible/ansible-kubernetes-v1.32.10.sh
```

### 完成安装

显示以下提示信息，所有节点都是 ok，failed=0

```bash
PLAY RECAP *******************************************************************************************************
beagle-01                  : ok=85   changed=65   unreachable=0    failed=0    skipped=23   rescued=0    ignored=6
beagle-02                  : ok=37   changed=32   unreachable=0    failed=0    skipped=6    rescued=0    ignored=1
beagle-03                  : ok=37   changed=32   unreachable=0    failed=0    skipped=6    rescued=0    ignored=1
```

### 验证安装

```bash
root@beagle-01:~# kubectl get node
NAME        STATUS   ROLES    AGE   VERSION
beagle-01   Ready    master   93s   v1.32.10-beagle
beagle-02   Ready    <none>   79s   v1.32.10-beagle
beagle-03   Ready    <none>   79s   v1.32.10-beagle

root@beagle-01:~# kubectl get pod -A -o wide
NAMESPACE     NAME                                READY   STATUS    RESTARTS   AGE   IP              NODE        NOMINATED NODE   READINESS GATES
kube-system   cilium-2zq4f                        1/1     Running   0          76s   192.168.1.202   beagle-02   <none>           <none>
kube-system   cilium-7tjl8                        1/1     Running   0          76s   192.168.1.203   beagle-03   <none>           <none>
kube-system   cilium-f8gcp                        1/1     Running   0          76s   192.168.1.201   beagle-01   <none>           <none>
kube-system   cilium-operator-7877c885b7-47ld8    1/1     Running   0          76s   192.168.1.202   beagle-02   <none>           <none>
kube-system   cilium-operator-7877c885b7-phjpf    1/1     Running   0          76s   192.168.1.203   beagle-03   <none>           <none>
kube-system   coredns-78dcd56fdf-ztqf6            1/1     Running   0          74s   10.2.0.134      beagle-01   <none>           <none>
kube-system   etcd-beagle-01                      1/1     Running   0          97s   192.168.1.201   beagle-01   <none>           <none>
kube-system   hubble-relay-84bff94f74-kclr9       1/1     Running   0          76s   10.2.0.234      beagle-01   <none>           <none>
kube-system   hubble-ui-596749dfc4-v2cxd          2/2     Running   0          76s   10.2.0.248      beagle-01   <none>           <none>
kube-system   kube-apiserver-beagle-01            1/1     Running   0          89s   192.168.1.201   beagle-01   <none>           <none>
kube-system   kube-controller-manager-beagle-01   1/1     Running   0          99s   192.168.1.201   beagle-01   <none>           <none>
kube-system   kube-scheduler-beagle-01            1/1     Running   0          99s   192.168.1.201   beagle-01   <none>           <none>
```

## FAQ

### Ubuntu 18.04 如何安装

尽量升级内核至 5.4 以上。请参考[Ubuntu-18.04.md](./docs/Ubuntu-18.04.md)

- Linux Kernel 3.10 时，将会默认安装 Flannel 网络插件
- 升级 Linux Kernel 至大于等于 4.9.17 时，将会安装 Cilium 网络插件

### 安装前准备

- 检查 python ， 确保服务器安装了 python2 或 python3
- 检查 iptable ， 确保服务器安装了 iptable
- 关闭防火墙 ， 确保服务器关闭了默认防火墙

### 安装历史版本 k8s

请参考[InstallHistoryVersion.md](./docs/InstallHistoryVersion.md)

- 1.28
- 1.26
- 1.24
