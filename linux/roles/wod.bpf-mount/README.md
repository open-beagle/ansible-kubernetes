# readme

```bash
cat <<EOF | sudo tee /etc/systemd/system/sys-fs-bpf.mount
[Unit]
Description=Cilium BPF mounts
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
```
