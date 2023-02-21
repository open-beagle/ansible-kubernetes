#!/bin/bash 

# REGISTRY_USER=beagle
# REGISTRY_PASS=beagle

PAUSE_IMAGE="${PAUSE_IMAGE:-registry.beagle.default:6444/k8s/pause:3.7}"

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
if ! [ -e /root/.docker/config.json ] ; then 
  mkdir -p /root/.docker/
  cat > /root/.docker/config.json <<\EOF
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
  containerd config default > /etc/containerd/config.toml
fi
if ! (grep -q $PAUSE_IMAGE /etc/containerd/config.toml) ; then 
  sed -i --expression "s?sandbox_image =.*?sandbox_image = \"$PAUSE_IMAGE\"?" /etc/containerd/config.toml
  sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
  RESTART_CONTAINERD=true
fi
if ! (grep -q "/etc/containerd/certs.d" /etc/containerd/config.toml) ; then 
  sed -i -e 's/config_path = ""/config_path = "\/etc\/containerd\/certs.d"/' /etc/containerd/config.toml
fi
if [ "$RESTART_CONTAINERD" = true ] ; then 
  systemctl restart containerd
fi
if ! (grep -q $K8S_DATA_PATH/containerd /etc/containerd/config.toml) ; then 
  sed -i --expression "s?root =.*?root = \"$K8S_DATA_PATH/containerd\"?" /etc/containerd/config.toml
fi