#!/bin/bash

export PATH=/opt/bin:$PATH

# REGISTRY_USER=beagle
# REGISTRY_PASS=beagle

PAUSE_IMAGE="${PAUSE_IMAGE:-registry.beagle.default:6444/k8s/pause:3.7}"
K8S_DATA_PATH="${K8S_DATA_PATH:-/data}"

# docker , 信任自签名证书和默认登录
mkdir -p /etc/docker/certs.d/registry.beagle.default:6444
if ! [ -e /etc/docker/certs.d/registry.beagle.default:6444/ca.crt ]; then
  cp /etc/kubernetes/ssl/ca.crt /etc/docker/certs.d/registry.beagle.default:6444/ca.crt
fi
if ! [ -e /root/.docker/config.json ]; then
  mkdir -p /root/.docker/
  cat >/root/.docker/config.json <<-EOF
{
	"auths": {
		"registry.beagle.default:6444": {
			"auth": "YmVhZ2xlOmJlYWdsZQ=="
		}
	}
}
EOF
  chmod 0600 /root/.docker/config.json
fi

# containerd , 信任自签名证书和默认登录
mkdir -p /etc/containerd/certs.d/registry.beagle.default:6444
if ! [ -e /etc/containerd/certs.d/registry.beagle.default:6444/ca.crt ]; then
  cp /etc/kubernetes/ssl/ca.crt /etc/containerd/certs.d/registry.beagle.default:6444/ca.crt
fi
if ! [ -e /etc/containerd/certs.d/registry.beagle.default:6444/hosts.toml ]; then
  cat >/etc/containerd/certs.d/registry.beagle.default:6444/hosts.toml <<-EOF
server = "https://registry.beagle.default:6444"

[host."https://registry.beagle.default:6444"]
  skip_verify = true
  [host."https://registry.beagle.default:6444".header]
    Authorization = "Basic YmVhZ2xlOmJlYWdsZQ=="
EOF
fi

# containerd , 信任自签名证书和默认登录
mkdir -p /etc/containerd
if ! [ -e /etc/containerd/config.toml ]; then
  containerd config default >/etc/containerd/config.toml
fi

# 在修改前备份配置文件
cp /etc/containerd/config.toml /etc/containerd/config.toml.bak

if ! [ -e /etc/containerd/config.yaml ]; then
  dasel -f /etc/containerd/config.toml -r toml -w yaml >/etc/containerd/config.yaml
fi

# 使用 yq 检查配置文件版本
CONFIG_VERSION=$(yq eval '.version' /etc/containerd/config.yaml)

## 修改sandbox镜像
if [ "$CONFIG_VERSION" = "2" ]; then
  yq eval ".plugins.\"io.containerd.grpc.v1.cri\".sandbox_image = \"$PAUSE_IMAGE\"" /etc/containerd/config.yaml -i
else
  yq eval ".plugins.\"io.containerd.cri.v1.images\".pinned_images.sandbox = \"$PAUSE_IMAGE\"" /etc/containerd/config.yaml -i
fi
## 修改registry配置
if [ "$CONFIG_VERSION" = "2" ]; then
  yq eval ".plugins.\"io.containerd.grpc.v1.cri\".registry.config_path = \"/etc/containerd/certs.d\"" /etc/containerd/config.yaml -i
else
  yq eval ".plugins.\"io.containerd.cri.v1.images\".registry.config_path = \"/etc/containerd/certs.d\"" /etc/containerd/config.yaml -i
fi
## 修改cgroup配置
if [ "$CONFIG_VERSION" = "2" ]; then
  yq eval ".plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.runc.options.SystemdCgroup = true" /etc/containerd/config.yaml -i
  yq eval ".plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.runc.options.rlimit_nofile = 65536" /etc/containerd/config.yaml -i
  yq eval ".plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.runc.options.rlimit_nproc = 4096" /etc/containerd/config.yaml -i
else
  yq eval ".plugins.\"io.containerd.cri.v1.runtime\".containerd.runtimes.runc.options.SystemdCgroup = true" /etc/containerd/config.yaml -i
  yq eval ".plugins.\"io.containerd.cri.v1.runtime\".containerd.runtimes.runc.options.rlimit_nofile = 65536" /etc/containerd/config.yaml -i
  yq eval ".plugins.\"io.containerd.cri.v1.runtime\".containerd.runtimes.runc.options.rlimit_nproc = 4096" /etc/containerd/config.yaml -i
fi
## 检查并修改nvidia runtime的rlimit配置（如果存在）
if [ "$CONFIG_VERSION" = "2" ]; then
  # 检查是否存在 nvidia runtime
  if yq eval ".plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.nvidia" /etc/containerd/config.yaml | grep -q "BinaryName"; then
    yq eval ".plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.nvidia.options.SystemdCgroup = true" /etc/containerd/config.yaml -i
    yq eval ".plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.nvidia.options.rlimit_nofile = 65536" /etc/containerd/config.yaml -i
    yq eval ".plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.nvidia.options.rlimit_nproc = 4096" /etc/containerd/config.yaml -i
  fi
else
  # 检查是否存在 nvidia runtime
  if yq eval ".plugins.\"io.containerd.cri.v1.runtime\".containerd.runtimes.nvidia" /etc/containerd/config.yaml | grep -q "BinaryName"; then
    yq eval ".plugins.\"io.containerd.cri.v1.runtime\".containerd.runtimes.nvidia.options.SystemdCgroup = true" /etc/containerd/config.yaml -i
    yq eval ".plugins.\"io.containerd.cri.v1.runtime\".containerd.runtimes.nvidia.options.rlimit_nofile = 65536" /etc/containerd/config.yaml -i
    yq eval ".plugins.\"io.containerd.cri.v1.runtime\".containerd.runtimes.nvidia.options.rlimit_nproc = 4096" /etc/containerd/config.yaml -i
  fi
fi
## 修改containerd根目录
yq eval ".root = \"$K8S_DATA_PATH/containerd\"" /etc/containerd/config.yaml -i

# 将修改后的配置转换回 toml 格式
dasel -f /etc/containerd/config.yaml -r yaml -w toml >/etc/containerd/config.toml
rm -rf /etc/containerd/config.yaml

# 使用 dasel 比较修改前后的配置文件
# 将两个 toml 文件转换为 json 格式进行比较
dasel -f /etc/containerd/config.toml.bak -r toml -w json >/tmp/config.bak.json
dasel -f /etc/containerd/config.toml -r toml -w json >/tmp/config.new.json

# 比较两个 JSON 文件的内容
if ! [ "$(cat /tmp/config.bak.json)" = "$(cat /tmp/config.new.json)" ]; then
  systemctl restart containerd
fi

# 清理临时文件
rm -f /tmp/config.bak.json /tmp/config.new.json /etc/containerd/config.toml.bak
