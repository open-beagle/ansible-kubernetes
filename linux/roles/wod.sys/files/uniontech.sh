#!/bin/bash

systemctl stop firewalld && systemctl disable firewalld

rm -rf /etc/cni/net.d

mkdir -p /etc/cni/net.d