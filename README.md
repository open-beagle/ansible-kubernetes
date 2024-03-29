# QuickStart Kubernetes Cluster

## 简介

- 快速搭建一个 Kubernetes 集群
- 搭建过程离线，无需访问外部的服务器
- 一行命令，使用 ansible，全程自动化

### 限制条件

- Linux Kernel >= 5.4 , 推荐 Ubuntu 22.04

### 核心组件

- 容器引擎: containerd 1.7
- 容器平台: kubernetes v1.24
- 数据库: etcd v3.5
- 网络组件: cilium v1.11
- 扩展组件: coredns 1.9

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

### 准备 yaml 配置文件 [可选]

请参考[all.yml](./linux/group_vars/all.yml)

```bash
mkdir -p /etc/kubernetes/ansible && \
rm -rf /etc/kubernetes/ansible/beagle.yaml && \
cat > /etc/kubernetes/ansible/beagle.yaml <<\EOF
## REGISTRY_LOCAL , Docker镜像服务器
## 安装过程种使用的容器镜像服务器
REGISTRY_LOCAL: 'registry.cn-qingdao.aliyuncs.com/wod'
```

### 开始安装

```bash
sudo curl -sfL https://cache.wodcloud.com/kubernetes/install.sh | sh -
```

## 离线一键安装 kubernetes 集群

### 准备 yaml 配置文件 [可选]

请参考[all.yml](./linux/group_vars/all.yml)

```bash
mkdir -p /etc/kubernetes/ansible && \
rm -rf /etc/kubernetes/ansible/beagle.yaml && \
cat > /etc/kubernetes/ansible/beagle.yaml <<\EOF
## REGISTRY_LOCAL , Docker镜像服务器
## 安装过程种使用的容器镜像服务器
REGISTRY_LOCAL: 'registry.beagle.default:6444/k8s'

## 容器存储路径
K8S_DATA_PATH: "/data/kubernetes"
EOF
```

### 准备文件

下载好安装所需资源及文件，运行脚本时整个安装过程完全离线。

```bash
# HTTPS服务器
export HTTP_SERVER=https://cache.wodcloud.com
# 平台架构
export TARGET_ARCH=amd64
# K8S版本
export K8S_VERSION=v1.24.17
# K8S发布版本
export K8S_RELEASE="${K8S_VERSION%.*}"

mkdir -p /etc/kubernetes/ansible
# 下载文件
curl $HTTP_SERVER/kubernetes/k8s/ansible/$K8S_RELEASE/$TARGET_ARCH/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz > /etc/kubernetes/ansible/ansible-docker-$K8S_VERSION-$TARGET_ARCH.tgz
curl $HTTP_SERVER/kubernetes/k8s/ansible/$K8S_RELEASE/$TARGET_ARCH/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz > /etc/kubernetes/ansible/ansible-kubernetes-images-$K8S_VERSION-$TARGET_ARCH.tgz
curl $HTTP_SERVER/kubernetes/k8s/ansible/$K8S_RELEASE/$TARGET_ARCH/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz > /etc/kubernetes/ansible/ansible-kubernetes-$K8S_VERSION-$TARGET_ARCH.tgz
# 下载脚本
curl $HTTP_SERVER/kubernetes/k8s/ansible/$K8S_RELEASE/$TARGET_ARCH/ansible-kubernetes-$K8S_VERSION.sh > /etc/kubernetes/ansible/ansible-kubernetes-$K8S_VERSION.sh

# 执行脚本
# bash /etc/kubernetes/ansible/ansible-kubernetes-v1.24.17.sh
bash /etc/kubernetes/ansible/ansible-kubernetes-$K8S_VERSION.sh
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
beagle-01   Ready    master   93s   v1.24.17-beagle
beagle-02   Ready    <none>   79s   v1.24.17-beagle
beagle-03   Ready    <none>   79s   v1.24.17-beagle

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

### TASK [wod.docker-login : login.sh] 中断

ERRO[0095] error waiting for container: unexpected EOF

- 执行安装任务时意外中断。
- 日志显示安装 wod.docker-login 任务时，中断
- 此任务为离线安装，准备镜像 Registry 服务，初始化认证参数时，需要重启 Containerd，重启 Containerd 导致退出容器。
- 如果安装服务器同时在本机上安装 K8S 节点则会导致中断。
- 忽略此错误，继续运行脚本 ansible-playbook 1.install.yml 可以解决问题。

### Ubuntu 18.04如何安装

尽量升级内核至5.4以上。请参考[Ubuntu-18.04.md](./docs/Ubuntu-18.04.md)

- Linux Kernel 4.10.x 时，将会默认安装Flannel网络插件
- 升级Linux Kernel 5.4.x 时，将会默认安装Cilium网络插件
