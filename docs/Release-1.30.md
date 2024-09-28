# v1.30

## docker

- 升级至 Containerd 2 , 注意/etc/containerd/config.toml 升级至 version 3
- 增加 yq，dasal 等命令，用于修改 toml 文件
- 增加 k8s-cni , iptables 等组件

## k8s-cni

- 移除 k8s-cni
- k8s-cni ，现在会通过 docker 组件完成安装，作为 docker 组件的一部分
