# QuickStart Kubernetes Cluster

## 简介

- 快速搭建一个 Kubernetes 集群
- 搭建过程离线，无需访问互联网
- 一行命令，使用 ansible，全程自动化

### 限制条件

- Linux Kernel >= 4.9.17 , 推荐 Ubuntu 22.04

### 核心组件

- 容器引擎: containerd 2.0
- 容器平台: kubernetes v1.30
- 数据库: etcd v3.5
- 网络组件: cilium v1.14
- 扩展组件: coredns 1.11

## 准备 hosts 文件

请参考[Ansible.md](./docs/Ansible.md)

```bash
mkdir -p /etc/kubernetes/ansible && \
rm -rf /etc/kubernetes/ansible/hosts.ini && \
cat > /etc/kubernetes/ansible/hosts.ini <<\EOF
[master]
beagle-01 ansible_ssh_host=192.168.1.201 ansible_ssh_port=22 ansible_ssh_user=root

[node]
beagle-02 ansible_ssh_host=192.168.1.202 ansible_ssh_port=22 ansible_ssh_user=root
beagle-03 ansible_ssh_host=192.168.1.203 ansible_ssh_port=22 ansible_ssh_user=root
EOF
```

## 在线一键安装 kubernetes 集群

配置文件请参考[all.yml](./linux/group_vars/all.yml)

```bash
# 准备 yaml 配置文件
mkdir -p /etc/kubernetes/ansible && \
  rm -rf /etc/kubernetes/ansible/beagle.yaml && \
  cat > /etc/kubernetes/ansible/beagle.yaml <<\EOF
REGISTRY_LOCAL: 'registry.cn-qingdao.aliyuncs.com/wod'
EOF

curl -sL https://cache.wodcloud.com/kubernetes/install.sh > /etc/kubernetes/ansible/install.sh && \
bash install.sh
```

### 开始安装

```bash

```

## 离线一键安装 kubernetes 集群

```bash
# 准备 yaml 配置文件
mkdir -p /etc/kubernetes/ansible && \
  rm -rf /etc/kubernetes/ansible/beagle.yaml && \
  cat > /etc/kubernetes/ansible/beagle.yaml <<\EOF
REGISTRY_LOCAL: 'registry.beagle.default:6444/k8s'
EOF

curl -sL https://cache.wodcloud.com/kubernetes/install.sh > /etc/kubernetes/ansible/install-offline.sh && \
bash install-offline.s
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
beagle-01   Ready    master   93s   v1.30.4-beagle
beagle-02   Ready    <none>   79s   v1.30.4-beagle
beagle-03   Ready    <none>   79s   v1.30.4-beagle

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
