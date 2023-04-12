#!/bin/bash 

systemctl daemon-reload

SERVICE=k8s-kubelet

if [ "`systemctl is-active $SERVICE`" == "active" ] ; then  
  systemctl stop $SERVICE
fi
rm -rf /etc/systemd/system/$SERVICE.service

SERVICE=k8s-etcd

if [ "`systemctl is-active $SERVICE`" == "active" ] ; then  
  systemctl stop $SERVICE
fi
rm -rf /etc/systemd/system/$SERVICE.service

SERVICE=k8s-registry

if [ "`systemctl is-active $SERVICE`" == "active" ] ; then  
  systemctl stop $SERVICE
fi
rm -rf /etc/systemd/system/$SERVICE.service

docker rm $(docker ps -a | awk '{print $1}') -f

docker system prune -a -f

rm -rf /etc/kubernetes /etc/cni/net.d /opt/cni/bin /opt/bin/helm /opt/bin/kubectl /opt/bin/kubelet /opt/bin/etcdctl /opt/bin/registry