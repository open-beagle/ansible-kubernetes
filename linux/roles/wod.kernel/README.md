# kernel

## CentOS x86_64

```bash
# https://elrepo.org/linux/kernel/el7/x86_64/RPMS/
kernel-lt-5.4.248-1.el7.elrepo.x86_64.rpm

export KERNEL_VERSION="5.4.248-1" && \
rm -rf ./.vscode/rpm && \
mkdir -p ./.vscode/rpm && \
curl -x socks5://www.ali.wodcloud.com:1283 https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-$KERNEL_VERSION.el7.elrepo.x86_64.rpm > ./.vscode/rpm/kernel-lt-$KERNEL_VERSION.el7.elrepo.x86_64.rpm && \
curl -x socks5://www.ali.wodcloud.com:1283 https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-headers-$KERNEL_VERSION.el7.elrepo.x86_64.rpm > ./.vscode/rpm/kernel-lt-headers-$KERNEL_VERSION.el7.elrepo.x86_64.rpm && \
mc cp --recursive ./.vscode/rpm/ cache/kubernetes/kernel/rpm
```

## CentOS arm64

```bash
# https://elrepo.org/linux/kernel/el9/aarch64/RPMS/
kernel-lt-6.1.35-1.el9.elrepo.aarch64.rpm

export KERNEL_VERSION="6.1.35-1" && \
rm -rf ./.vscode/rpm && \
mkdir -p ./.vscode/rpm && \
curl -x socks5://www.ali.wodcloud.com:1283 https://elrepo.org/linux/kernel/el9/aarch64/RPMS/kernel-lt-$KERNEL_VERSION.el9.elrepo.aarch64.rpm > ./.vscode/rpm/kernel-lt-$KERNEL_VERSION.el9.elrepo.aarch64.rpm && \
curl -x socks5://www.ali.wodcloud.com:1283 https://elrepo.org/linux/kernel/el9/aarch64/RPMS/kernel-lt-core-$KERNEL_VERSION.el9.elrepo.aarch64.rpm > ./.vscode/rpm/kernel-lt-core-$KERNEL_VERSION.el9.elrepo.aarch64.rpm && \
curl -x socks5://www.ali.wodcloud.com:1283 https://elrepo.org/linux/kernel/el9/aarch64/RPMS/kernel-lt-headers-$KERNEL_VERSION.el9.elrepo.aarch64.rpm > ./.vscode/rpm/kernel-lt-headers-$KERNEL_VERSION.el9.elrepo.aarch64.rpm && \
mc cp --recursive ./.vscode/rpm/ cache/kubernetes/kernel/rpm
```

## Ubuntu x86_64

- v5.4与v5.10的选择
- Ubuntu 18.04最高可以升级至v5.4
- Ubuntu 22.04默认提供v5.10

```bash
# https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.246/
linux-headers-5.4.246-0504246-generic_5.4.246-0504246.202306090538_amd64.deb
linux-image-unsigned-5.4.246-0504246-generic_5.4.246-0504246.202306090538_amd64.deb
linux-modules-5.4.246-0504246-generic_5.4.246-0504246.202306090538_amd64.deb

export KERNEL_VERSION="5.4.246-0504246-generic_5.4.246-0504246.202306090538" && \
rm -rf ./.vscode/deb && \
mkdir -p ./.vscode/deb && \
curl -x socks5://www.ali.wodcloud.com:1283 https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.246/amd64/linux-headers-${KERNEL_VERSION}_amd64.deb > ./.vscode/deb/linux-headers-${KERNEL_VERSION}_amd64.deb && \
curl -x socks5://www.ali.wodcloud.com:1283 https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.246/amd64/linux-modules-${KERNEL_VERSION}_amd64.deb > ./.vscode/deb/linux-modules-${KERNEL_VERSION}_amd64.deb && \
curl -x socks5://www.ali.wodcloud.com:1283 https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.246/amd64/linux-image-unsigned-${KERNEL_VERSION}_amd64.deb > ./.vscode/deb/linux-image-unsigned-${KERNEL_VERSION}_amd64.deb && \
mc cp --recursive ./.vscode/deb/ cache/kubernetes/kernel/deb
```

## Ubuntu arm64

```bash
# https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.10.133/arm64/
linux-headers-5.4.246-0504246-generic_5.4.246-0504246.202306090538_arm64.deb
linux-image-unsigned-5.4.246-0504246-generic_5.4.246-0504246.202306090538_arm64.deb
linux-modules-5.4.246-0504246-generic_5.4.246-0504246.202306090538_arm64.deb

export KERNEL_VERSION="5.4.246-0504246-generic_5.4.246-0504246.202306090538" && \
rm -rf ./.vscode/deb && \
mkdir -p ./.vscode/deb && \
curl -x socks5://www.ali.wodcloud.com:1283 https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.246/arm64/linux-headers-${KERNEL_VERSION}_arm64.deb > ./.vscode/deb/linux-headers-${KERNEL_VERSION}_arm64.deb && \
curl -x socks5://www.ali.wodcloud.com:1283 https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.246/arm64/linux-modules-${KERNEL_VERSION}_arm64.deb > ./.vscode/deb/linux-modules-${KERNEL_VERSION}_arm64.deb && \
curl -x socks5://www.ali.wodcloud.com:1283 https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.246/arm64/linux-image-unsigned-${KERNEL_VERSION}_arm64.deb > ./.vscode/deb/linux-image-unsigned-${KERNEL_VERSION}_arm64.deb && \
mc cp --recursive ./.vscode/deb/ cache/kubernetes/kernel/deb
```
