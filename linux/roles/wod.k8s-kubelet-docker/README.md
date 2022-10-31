# k8s-kubelet-docker

用于 1.22 以下版本安装 kubelet 服务

## cgroupDriver : cgroupfs & systemd

- cgroupfs ，第一代 cgroup 管理器
- systemd，第二代 cgroup 管理器

### cgroupDriver 与 docker

在 Linux Kernel 默认低于 4.19 以下的版本，安装 docker 时，默认选择的驱动是 cgroupfs，例如

- Ubuntu 18.04

在 Linux Kernel 默认高于 5.4 以上的版本，安装 docker 时，默认选择的驱动是 systemd，例如

- Ubuntu 22.04

如果安装 k8s 的版本为 1.18 时，需要根据 docker 的默认 cgroupDriver 做设置，否则由于 cgroup 驱动接口匹配原因会导致 kubelet 启动失败

### docker 的持续更新

docker 的持续更新导致现在会跟着操作系统来变换这个 cgroup 驱动。
