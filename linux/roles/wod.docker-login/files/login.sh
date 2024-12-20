#!/bin/bash

export PATH=/opt/bin:$PATH

# REGISTRY_USER=beagle
# REGISTRY_PASS=beagle

PAUSE_IMAGE="${PAUSE_IMAGE:-registry.beagle.default:6444/k8s/pause:3.7}"
K8S_DATA_PATH="${K8S_DATA_PATH:-/var/lib}"

# docker , 信任自签名证书和默认登录
mkdir -p /etc/docker/certs.d/registry.beagle.default:6444
if ! [ -e /etc/docker/certs.d/registry.beagle.default:6444/ca.crt ]; then
  cp /etc/kubernetes/ssl/ca.crt /etc/docker/certs.d/registry.beagle.default:6444/ca.crt
fi
# containerd , 信任自签名证书和默认登录
mkdir -p /etc/containerd/certs.d/registry.beagle.default:6444
if ! [ -e /etc/containerd/certs.d/registry.beagle.default:6444/ca.crt ]; then
  cp /etc/kubernetes/ssl/ca.crt /etc/containerd/certs.d/registry.beagle.default:6444/ca.crt
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

RESTART_CONTAINERD=false
# containerd , 信任自签名证书和默认登录
mkdir -p /etc/containerd
if ! [ -e /etc/containerd/config.toml ]; then
  containerd config default >/etc/containerd/config.toml
fi
if ! [ -e /etc/containerd/config.yaml ]; then
  dasel -f /etc/containerd/config.toml -r toml -w yaml >/etc/containerd/config.yaml
fi
if ! (grep -q $PAUSE_IMAGE /etc/containerd/config.toml); then
  RESTART_CONTAINERD=true
  yq eval ".plugins.\"io.containerd.grpc.v1.cri\".sandbox_image = \"$PAUSE_IMAGE\"" /etc/containerd/config.yaml -i
fi
if ! (grep -q "/etc/containerd/certs.d" /etc/containerd/config.toml); then
  RESTART_CONTAINERD=true
  yq eval ".plugins.\"io.containerd.grpc.v1.cri\".registry.config_path = \"/etc/containerd/certs.d\"" /etc/containerd/config.yaml -i
fi
if ! (grep -q "SystemdCgroup = true" /etc/containerd/config.toml); then
  RESTART_CONTAINERD=true
  yq eval ".plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.runc.options.SystemdCgroup = true" /etc/containerd/config.yaml -i
fi
if ! (grep -q "root = \"$K8S_DATA_PATH/containerd\"" /etc/containerd/config.toml); then
  RESTART_CONTAINERD=true
  yq eval ".root = \"$K8S_DATA_PATH/containerd\"" /etc/containerd/config.yaml -i
fi
if [ "$RESTART_CONTAINERD" = true ]; then
  dasel -f /etc/containerd/config.yaml -r yaml -w toml >/etc/containerd/config.toml
  rm -rf /etc/containerd/config.yaml
  systemctl restart containerd
fi

rm -rf /etc/containerd/config.yaml
