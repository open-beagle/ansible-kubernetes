# NetworkPlugin

网络组件与选型

## 可选网络组件

- Linux内核 >= v3.10 ， 使用flannel网络组件，需要安装kube-proxy.
- Linux内核 >= v4.9.17 ， 使用cilium网络组件，需要安装kube-proxy.
- Linux内核 >= v4.19.57 ，使用cilium网络组件.
- Linux内核 >= v5.1 ，使用cilium网络组件 , Bandwith Manager网络带宽管理功能开放.
- Linux内核 >= v5.2 ，使用cilium网络组件 , Egress Gateway出口带宽管理功能开放.
- Linux内核 >= v5.6 ，使用cilium网络组件 , 可使用WireGuard对传输流量进行双向加密.
- Linux内核 >= v5.7 ，使用cilium网络组件 , 支持基于ClientIP的会话保持功能.
- Linux内核 >= v5.10 ，使用cilium网络组件 , 支持基于BPF的主机路由.

## 注意

- 尽量使用最新内核，以便cilium获得更好性能，推荐内核为v5.10
- 关于龙芯架构，推荐使用v6以上的内核，v6以上内核是支持龙芯的，下面的内核都仅能做到兼容。
