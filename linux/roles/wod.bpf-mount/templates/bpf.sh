#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

LOCAL_ARCH=$(uname -m)

if [ "$LOCAL_ARCH" = "x86_64" ]; then
  TARGET_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "ppc64le" ]; then
  TARGET_ARCH="ppc64le"
  exit 0 
elif [ "$LOCAL_ARCH" = "mips64" ]; then
  TARGET_ARCH="mips64le"
  exit 0 
else
  echo "This system's architecture $(LOCAL_ARCH) isn't supported"
  TARGET_ARCH="unsupported"
  exit 0 
fi

mount | grep "/sys/fs/bpf type bpf" || {
  # Mount the filesystem until next reboot
  echo "Mounting BPF filesystem..."
  mount bpffs /sys/fs/bpf -t bpf

  # Configure systemd to mount after next boot
  echo "Installing BPF filesystem mount"
  cat >/tmp/sys-fs-bpf.mount <<EOF
[Unit]
Description=Mount BPF filesystem (Cilium)
Documentation=http://docs.cilium.io/
DefaultDependencies=no
Before=local-fs.target umount.target
After=swap.target

[Mount]
What=bpffs
Where=/sys/fs/bpf
Type=bpf
Options=rw,nosuid,nodev,noexec,relatime,mode=700

[Install]
WantedBy=multi-user.target
EOF

  if [ -d "/etc/systemd/system/" ]; then
    mv /tmp/sys-fs-bpf.mount /etc/systemd/system/
    echo "Installed sys-fs-bpf.mount to /etc/systemd/system/"
  elif [ -d "/lib/systemd/system/" ]; then
    mv /tmp/sys-fs-bpf.mount /lib/systemd/system/
    echo "Installed sys-fs-bpf.mount to /lib/systemd/system/"
  fi

  # Ensure that filesystem gets mounted on next reboot
  systemctl daemon-reload
  systemctl enable sys-fs-bpf.mount
  systemctl start sys-fs-bpf.mount
}