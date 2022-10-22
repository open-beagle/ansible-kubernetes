# Ubuntu 18.04

前置条件

- 确保内核Linux Kernel >= 5.4

## 升级内核

### 在线安装内核

```bash
curl -sfL https://cache.wodcloud.com/kubernetes/kernel/install-kernel-Ubuntu.sh | sh -
```

### 离线安装内核

```bash
# 准备内核文件
mkdir -p /etc/kubernetes/ansible
HTTP_SERVER=https://cache.wodcloud.com/kubernetes
TARGET_ARCH="amd64"
KERNEL_VERSION="5.4.219-0504219"
KERNEL_RELEASE="202210171633"
LINUX_HEADERS_ALL="linux-headers-${KERNEL_VERSION}_${KERNEL_VERSION}.${KERNEL_RELEASE}_all"
LINUX_HEADERS="linux-headers-${KERNEL_VERSION}-generic_${KERNEL_VERSION}.${KERNEL_RELEASE}_${TARGET_ARCH}"
LINUX_IMAGE="linux-image-unsigned-${KERNEL_VERSION}-generic_${KERNEL_VERSION}.${KERNEL_RELEASE}_${TARGET_ARCH}"
LINUX_MODULES="linux-modules-${KERNEL_VERSION}-generic_${KERNEL_VERSION}.${KERNEL_RELEASE}_${TARGET_ARCH}"
curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_HEADERS_ALL.deb > /etc/kubernetes/ansible/$LINUX_HEADERS_ALL.deb
curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_HEADERS.deb > /etc/kubernetes/ansible/$LINUX_HEADERS.deb
curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_IMAGE.deb > /etc/kubernetes/ansible/$LINUX_IMAGE.deb
curl $HTTP_SERVER/kernel/deb/v5.4/$TARGET_ARCH/$LINUX_MODULES.deb > /etc/kubernetes/ansible/$LINUX_MODULES.deb

# 安装内核
dpkg -i /etc/kubernetes/ansible/$LINUX_MODULES.deb
dpkg -i /etc/kubernetes/ansible/$LINUX_HEADERS_ALL.deb
dpkg -i /etc/kubernetes/ansible/$LINUX_HEADERS.deb
dpkg -i /etc/kubernetes/ansible/$LINUX_IMAGE.deb

# 重启服务器
reboot

# 检查内核
# 5.4.219-0504219-generic
uname -ar
```

### 调试代码安装内核

源码位置：wod.kernel

```bash
# 使用代码安装
docker run \
-t --rm \
-v $PWD/:/etc/ansible \
-v $PWD/.vscode/hosts.ini:/etc/ansible/hosts \
-w /etc/ansible/linux \
registry.cn-qingdao.aliyuncs.com/wod/ansible:2 \
ansible-playbook 5.kernel.yml

# 检查服务器内核
docker run \
-t --rm \
-v $PWD/:/etc/ansible \
-v $PWD/.vscode/hosts.ini:/etc/ansible/hosts \
-w /etc/ansible/linux \
registry.cn-qingdao.aliyuncs.com/wod/ansible:2 \
ansible-playbook 8.test-var.yml
```
