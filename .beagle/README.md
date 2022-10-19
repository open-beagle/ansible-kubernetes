# Debug

## Download Files

```bash
bash .beagle/install.sh
```

## Debug In Containers

```bash
# 安装一个主节点，多个Node
docker run \
-it --rm \
-v $PWD/:/etc/ansible \
-v $PWD/.vscode/hosts.ini:/etc/ansible/hosts \
-w /etc/ansible/linux \
--entrypoint=bash \
registry.cn-qingdao.aliyuncs.com/wod/ansible:2

# 离线安装kubernetes集群
ap 1.install.yml \
--extra-vars "K8S_ADMIN_TOKEN=pleasechangeit"

# 在线安装kubernetes集群
ap 1.install.yml \
--extra-vars "K8S_ADMIN_TOKEN=pleasechangeit" \
--extra-vars "REGISTRY_LOCAL=registry.cn-qingdao.aliyuncs.com/wod"

# 检查内核
ansible all -m shell -a 'uname -r'

# 重新安装docker
ansible all -m shell -a 'rm -rf /opt/docker'
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
-e PLUGIN_YAML=linux/group_vars/all.yml \
-e PLUGIN_IMAGE=K8S_IMAGES \
-e PLUGIN_ARCH=amd64 \
-e PLUGIN_GROUP=k8s \
-e PLUGIN_RELEASE=linux/roles/wod.registry/files/images/ansible-kubernetes-images-v1.24.7-amd64.tgz \
-w $PWD \
registry.cn-qingdao.aliyuncs.com/wod/devops-docker-images:1.0
```

### Update Images

```bash
docker run -it --rm \
-v $PWD/:$PWD/ \
-e CI_WORKSPACE=$PWD \
-e PLUGIN_TARGET=192.168.1.200:6444,192.168.1.201:6444,192.168.1.202:6444 \
-e PLUGIN_TLS=insecure \
-e PLUGIN_USER=beagle \
-e PLUGIN_PASS=beagle \
-e PLUGIN_RELEASE=$PWD/beagle-kubernetes-images-v1.24.7-amd64.tgz \
-w $PWD \
registry.beagle.default:6444/k8s/devops-docker-images:1.0
```

### Pause Image

- kubelet 的pod-infra-container-image参数是专门给DockerShim用的，已过期
- 需要设置/etc/containerd/config.toml的节

```toml
[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.k8s.io/pause:3.2"
```

- 设置过后重启Containerd方能生效。

```bash
systemctl restart containerd
```
