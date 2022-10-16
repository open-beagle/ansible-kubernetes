#!/bin/bash

set -ex

systemctl stop docker.service
systemctl stop docker.socket
systemctl stop containerd.service

systemctl disable containerd.service
systemctl disable docker.socket 
systemctl disable docker.service 

rm -rf /usr/local/bin/docker /usr/local/bin/dockerd /usr/local/bin/docker-init /usr/local/bin/docker-proxy
rm -rf /usr/local/bin/ctr /usr/local/bin/containerd /usr/local/bin/containerd-shim /usr/local/bin/containerd-shim-runc-v2
rm -rf /usr/local/bin/runc

rm -rf /usr/bin/docker /usr/bin/dockerd /usr/bin/docker-init /usr/bin/docker-proxy
rm -rf /usr/bin/ctr /usr/bin/containerd /usr/bin/containerd-shim /usr/bin/containerd-shim-runc-v2
rm -rf /usr/bin/runc

rm -rf /opt/bin/docker /opt/bin/dockerd /opt/bin/docker-init /opt/bin/docker-proxy
rm -rf /opt/bin/ctr /opt/bin/containerd /opt/bin/containerd-shim /opt/bin/containerd-shim-runc-v2
rm -rf /opt/bin/runc