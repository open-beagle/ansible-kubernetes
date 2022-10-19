#!/bin/bash

DOCKER_VERSION="${DOCKER_VERSION:-20.10.18}"

LOCAL_ARCH=$(uname -m)

if [ "$LOCAL_ARCH" = "x86_64" ]; then
  TARGET_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "ppc64le" ]; then
  TARGET_ARCH="ppc64le"
elif [ "$LOCAL_ARCH" = "mips64" ]; then
  TARGET_ARCH="mips64le"
else
  echo "This system's architecture $(LOCAL_ARCH) isn't supported"
  TARGET_ARCH="unsupported"
  exit 0 
fi

mkdir -p /opt/bin /opt/docker

if ! [ -e /opt/docker/.groupadddocker ]; then
	groupadd docker
  touch /opt/docker/.groupadddocker
fi

ENV_OPT="/opt/bin:$PATH"
if ! (grep -q /opt/bin /etc/environment) ; then
  cat > /etc/environment <<-EOF
PATH="${ENV_OPT}"
EOF
fi
source /etc/environment

set -ex

if [ -e /opt/docker/VERSION-$DOCKER_VERSION.md ]; then
  exit 0 
fi

rm -rf /opt/docker/$DOCKER_VERSION
tar -xzvf /opt/docker/docker-$DOCKER_VERSION.tgz -C /opt/docker/
mv /opt/docker/docker /opt/docker/$DOCKER_VERSION
rm -rf /opt/docker/docker-$DOCKER_VERSION.tgz
touch /opt/docker/VERSION-$DOCKER_VERSION.md

rm -rf /opt/bin/docker /opt/bin/dockerd /opt/bin/docker-init /opt/bin/docker-proxy
cp /opt/docker/$DOCKER_VERSION/docker /opt/bin/docker
cp /opt/docker/$DOCKER_VERSION/dockerd /opt/bin/dockerd
cp /opt/docker/$DOCKER_VERSION/docker-init /opt/bin/docker-init

rm -rf /opt/bin/ctr /opt/bin/containerd /opt/bin/containerd-shim /opt/bin/containerd-shim-runc-v2
cp /opt/docker/$DOCKER_VERSION/ctr /opt/bin/ctr
cp /opt/docker/$DOCKER_VERSION/containerd /opt/bin/containerd
cp /opt/docker/$DOCKER_VERSION/containerd-shim /opt/bin/containerd-shim
cp /opt/docker/$DOCKER_VERSION/containerd-shim-runc-v2 /opt/bin/containerd-shim-runc-v2

rm -rf /opt/bin/runc
cp /opt/docker/$DOCKER_VERSION/runc /opt/bin/runc

rm -rf /usr/local/bin/docker /usr/local/bin/dockerd /usr/local/bin/docker-init /usr/local/bin/docker-proxy
ln -s /opt/docker/$DOCKER_VERSION/docker /usr/local/bin/docker
ln -s /opt/docker/$DOCKER_VERSION/dockerd /usr/local/bin/dockerd
ln -s /opt/docker/$DOCKER_VERSION/docker-init /usr/local/bin/docker-init

rm -rf /usr/local/bin/ctr /usr/local/bin/containerd /usr/local/bin/containerd-shim /usr/local/bin/containerd-shim-runc-v2
ln -s /opt/docker/$DOCKER_VERSION/ctr /usr/local/bin/ctr
ln -s /opt/docker/$DOCKER_VERSION/containerd /usr/local/bin/containerd
ln -s /opt/docker/$DOCKER_VERSION/containerd-shim /usr/local/bin/containerd-shim
ln -s /opt/docker/$DOCKER_VERSION/containerd-shim-runc-v2 /usr/local/bin/containerd-shim-runc-v2

rm -rf /usr/local/bin/runc
ln -s /opt/docker/$DOCKER_VERSION/runc /usr/local/bin/runc

cat > /etc/systemd/system/containerd.service <<\EOF
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
#uncomment to enable the experimental sbservice (sandboxed) version of containerd/cri integration
#Environment="ENABLE_CRI_SANDBOXES=sandboxed"
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/opt/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target

EOF

cat > /etc/systemd/system/docker.socket <<\EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target

EOF

cat > /etc/systemd/system/docker.service <<\EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target containerd.service
Requires=docker.socket 

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
Environment=PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
ExecStart=/opt/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target

EOF

mkdir -p /etc/docker/
if ! [ -e /etc/docker/daemon.json ]; then  
  cat >> /etc/docker/daemon.json <<-EOF
{
  "live-restore": true
}
EOF
fi

# containerd , 信任自签名证书和默认登录
mkdir -p /etc/containerd
if ! [ -e /etc/containerd/config.toml ]; then  
  containerd config default > /etc/containerd/config.toml
fi
if ! (grep -q "YmVhZ2xlOmJlYWdsZQ==" /etc/containerd/config.toml) ; then 
  cat >> /etc/containerd/config.toml <<-EOF

[plugins."io.containerd.grpc.v1.cri".registry.configs."registry.beagle.default:6444".tls]
ca_file = "/etc/kubernetes/ssl/ca.crt"
[plugins."io.containerd.grpc.v1.cri".registry.configs."registry.beagle.default:6444".auth]
auth = "YmVhZ2xlOmJlYWdsZQ=="
EOF
  sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
fi

systemctl daemon-reload
systemctl enable containerd.service && systemctl restart containerd.service
systemctl enable docker.socket && systemctl restart docker.socket
systemctl enable docker.service && systemctl restart docker.service
