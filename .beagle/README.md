# Debug

## Download Files

```bash
# 在线安装
bash .beagle/install.sh

# 离线安装
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-kubernetes-images-v1.30.14-amd64.tgz >$PWD/linux/roles/wod.registry/files/images/ansible-kubernetes-images-v1.30.14-amd64.tgz
```

## Debug In Containers

```bash
# 安装一个主节点，多个Node
docker pull registry.cn-qingdao.aliyuncs.com/wod/ansible:2 && \
docker run \
-it --rm \
-v $PWD/:/etc/ansible \
-v $PWD/.vscode/ansible-kubernetes.ini:/etc/ansible/hosts \
-w /etc/ansible \
--entrypoint=bash \
registry.cn-qingdao.aliyuncs.com/wod/ansible:2

# 使用自定义配置安装集群
ap linux/1.install.yml \
--extra-vars "@./.vscode/ansible-kubernetes.yml"

# 使用自定义配置升级集群
ap linux/4.update.yml \
--extra-vars "@./.vscode/ansible-kubernetes.yml"

# 离线安装kubernetes集群
ap linux/1.install.yml

# 在线安装kubernetes集群
ap linux/1.install.yml \
--extra-vars "REGISTRY_LOCAL=registry.cn-qingdao.aliyuncs.com/wod"

# 检查内核
ansible all -m shell -a 'uname -r'

# 安装内核
ansible all -m shell -a 'curl -fL https://cache.ali.wodcloud.com/kubernetes/kernel/install-Ubuntu.sh | sh -'

# 重新安装docker
ansible all -m shell -a 'rm -rf /opt/docker'
```

## Debug Multi Version

```bash
# 1.26
docker run \
-it --rm \
-v $PWD/:/etc/ansible \
-v $PWD/.vscode/ansible-kubernetes.ini:/etc/ansible/hosts \
-w /etc/ansible/linux \
registry.cn-qingdao.aliyuncs.com/wod/ansible:2 \
ansible-playbook 1.install.yml \
--extra-vars "@./vars/1.26.yml" \
--extra-vars "REGISTRY_LOCAL=registry.cn-qingdao.aliyuncs.com/wod"

# 1.24
docker run \
-it --rm \
-v $PWD/:/etc/ansible \
-v $PWD/.vscode/ansible-kubernetes.ini:/etc/ansible/hosts \
-w /etc/ansible/linux \
registry.cn-qingdao.aliyuncs.com/wod/ansible:2 \
ansible-playbook 1.install.yml \
--extra-vars "@./vars/1.24.yml" \
--extra-vars "REGISTRY_LOCAL=registry.cn-qingdao.aliyuncs.com/wod"

# 1.22
docker run \
-it --rm \
-v $PWD/:/etc/ansible \
-v $PWD/.vscode/ansible-kubernetes.ini:/etc/ansible/hosts \
-w /etc/ansible/linux \
registry.cn-qingdao.aliyuncs.com/wod/ansible:2 \
ansible-playbook 1.install.yml \
--extra-vars "@./vars/1.22.yml" \
--extra-vars "REGISTRY_LOCAL=registry.cn-qingdao.aliyuncs.com/wod"

# 1.20
docker run \
-it --rm \
-v $PWD/:/etc/ansible \
-v $PWD/.vscode/ansible-kubernetes.ini:/etc/ansible/hosts \
-w /etc/ansible/linux \
registry.cn-qingdao.aliyuncs.com/wod/ansible:2 \
ansible-playbook 1.install.yml \
--extra-vars "@./vars/1.20.yml" \
--extra-vars "REGISTRY_LOCAL=registry.cn-qingdao.aliyuncs.com/wod"

# 1.18
# 仅测试通过Ubuntu 18.04
docker run \
-it --rm \
-v $PWD/:/etc/ansible \
-v $PWD/.vscode/ansible-kubernetes.ini:/etc/ansible/hosts \
-w /etc/ansible/linux \
registry.cn-qingdao.aliyuncs.com/wod/ansible:2 \
ansible-playbook 1.install.yml \
--extra-vars "@./vars/1.18.yml" \
--extra-vars "REGISTRY_LOCAL=registry.cn-qingdao.aliyuncs.com/wod"
```

## Components

### kubectl 自动完成

```bash
# 在 ~/.bashrc 中加上一行
# source <(/opt/bin/kubectl completion bash)
# 运行时，报以下错误_get_comp_words_by_ref: command not found

kubectl -n kube-system exec cilium-kn-bash: _get_comp_words_by_ref: command not found

# 修复方式

apt install -y bash-completion
```

### 生成 registry 的访问密码

```bash
docker run -it --rm \
  --entrypoint htpasswd \
  httpd:2 -Bbn beagle beagle > $PWD/linux/roles/wod.registry/files/auth
```

### Release Images

```bash
rm -rf .registry && \
rm -rf linux/roles/wod.registry/files/images/*.tgz && \
docker pull registry.cn-qingdao.aliyuncs.com/wod/devops-docker-images:1.0 && \
docker run -it --rm \
-v $PWD/:$PWD/ \
-e CI_WORKSPACE=$PWD \
-e PLUGIN_SOURCE=registry.cn-qingdao.aliyuncs.com/wod \
-e PLUGIN_YAML=linux/vars/1.26.yml \
-e PLUGIN_IMAGE=K8S_IMAGES \
-e PLUGIN_ARCH=amd64 \
-e PLUGIN_GROUP=k8s \
-e PLUGIN_RELEASE=linux/roles/wod.registry/files/images/ansible-kubernetes-images-v1.26.15-amd64.tgz \
-w $PWD \
registry.beagle.default:6444/k8s/devops-docker-images:1.0
```

### Update Images

```bash
docker run -it --rm \
-v $PWD/:$PWD/ \
-e CI_WORKSPACE=$PWD \
-e PLUGIN_TARGET=192.168.1.201:6444,192.168.1.202:6444,192.168.1.203:6444 \
-e PLUGIN_TLS=insecure \
-e PLUGIN_USER=beagle \
-e PLUGIN_PASS=beagle \
-e PLUGIN_RELEASE=$PWD/beagle-kubernetes-images-v1.26.15-amd64.tgz \
-w $PWD \
registry.beagle.default:6444/k8s/devops-docker-images:1.0
```

### Pause Image

- kubelet 的 pod-infra-container-image 参数是专门给 DockerShim 用的，已过期
- 需要设置/etc/containerd/config.toml 的节

```toml
[plugins."io.containerd.grpc.v1.cri"]
  sandbox = "registry.k8s.io/pause:3.2"
```

- 设置过后重启 Containerd 方能生效。

```bash
systemctl restart containerd
```

### 安装测试

```bash
# 在线安装k8s
# 安装docker
mkdir -p /opt/docker && \
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-docker.sh > /opt/docker/ansible-docker.sh && \
bash /opt/docker/ansible-docker.sh

# 安装k8s
mkdir -p /etc/kubernetes/ansible && \
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-kubernetes.sh > /etc/kubernetes/ansible/ansible-kubernetes.sh && \
bash /etc/kubernetes/ansible/ansible-kubernetes.sh

# 离线安装k8s
# 安装docker
# HTTP_SERVER=https://cache.ali.wodcloud.com
# TARGET_ARCH=amd64;arm64;
mkdir -p /opt/docker && \
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-docker-28.3.2-amd64.tgz > /opt/docker/ansible-docker-28.3.2-amd64.tgz && \
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-docker.sh > /opt/docker/ansible-docker.sh && \
export DOCKER_VERSION=28.3.2 && \
bash /opt/docker/ansible-docker.sh

# 开始安装k8s
mkdir -p /etc/kubernetes/ansible && \
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-kubernetes-images-v1.30.14-amd64.tgz >/etc/kubernetes/ansible/ansible-kubernetes-images-v1.30.14-amd64.tgz && \
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-kubernetes-v1.30.14-amd64.tgz >/etc/kubernetes/ansible/ansible-kubernetes-v1.30.14-amd64.tgz && \
curl -fL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-kubernetes-v1.30.14.sh > /etc/kubernetes/ansible/ansible-kubernetes-v1.30.14.sh && \
export K8S_VERSION=v1.30.14 && \
export ANSIBLE_K8S_VERSION=v1.30.14 && \
bash /etc/kubernetes/ansible/ansible-kubernetes-v1.30.14.sh
```

## cache

```bash
# 构建缓存-->推送缓存至服务器
docker run --rm \
  -e PLUGIN_REBUILD=true \
  -e PLUGIN_ENDPOINT=${S3_ENDPOINT_ALIYUN} \
  -e PLUGIN_ACCESS_KEY=${S3_ACCESS_KEY_ALIYUN} \
  -e PLUGIN_SECRET_KEY=${S3_SECRET_KEY_ALIYUN} \
  -e DRONE_REPO_OWNER="open-beagle" \
  -e DRONE_REPO_NAME="ansible-kubernetes" \
  -e PLUGIN_MOUNT="./.git" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0

# 读取缓存-->将缓存从服务器拉取到本地
docker run --rm \
  -e PLUGIN_RESTORE=true \
  -e PLUGIN_ENDPOINT=${S3_ENDPOINT_ALIYUN} \
  -e PLUGIN_ACCESS_KEY=${S3_ACCESS_KEY_ALIYUN} \
  -e PLUGIN_SECRET_KEY=${S3_SECRET_KEY_ALIYUN} \
  -e DRONE_REPO_OWNER="open-beagle" \
  -e DRONE_REPO_NAME="ansible-kubernetes" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0
```
