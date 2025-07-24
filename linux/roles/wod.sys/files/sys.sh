#!/bin/bash

set -ex

mkdir -p /etc/kubernetes/scripts /etc/kubernetes/manifests /usr/share/ca-certificates /usr/libexec/kubernetes

# 设置authorized_keys
if ! [ -e /etc/kubernetes/scripts/authorized_keys.sh ] ; then 
  AUTHORIZED_KEYS="${AUTHORIZED_KEYS}"

  if ! [ -e /root/.ssh/authorized_keys ]; then
    mkdir -p /root/.ssh/
    touch /root/.ssh/authorized_keys create file
  fi

  IFS=","
  KEYS=(${AUTHORIZED_KEYS})
  for key in ${KEYS[@]}; do
    IFS=" "
    keyarr=(${key})
    if ! (grep -q ${keyarr[2]} /root/.ssh/authorized_keys) ; then
      echo " " >> /root/.ssh/authorized_keys;
      echo "${key}" >> /root/.ssh/authorized_keys;
    fi
  done
  touch /etc/kubernetes/scripts/authorized_keys.sh
fi

# 设置时区
if ! [ -e /etc/kubernetes/scripts/timezone.sh ] ; then 
  timedatectl set-timezone Asia/Shanghai
  touch /etc/kubernetes/scripts/timezone.sh
fi

# mkdir
if ! [ -e /usr/bin/mkdir ] ; then 
  if [ -e /bin/mkdir ] ; then 
    ln -s /bin/mkdir /usr/bin/mkdir
  fi
fi

# 关闭swap分区
if ! [ -e /usr/bin/swapoff ] ; then 
  if [ -e /sbin/swapoff ] ; then 
    ln -s /sbin/swapoff /usr/bin/swapoff
  elif [ -e /usr/sbin/swapoff ] ; then 
    ln -s /usr/sbin/swapoff /usr/bin/swapoff
  fi
fi
if ! [ -e /etc/kubernetes/scripts/swap.sh ] ; then 
  swapoff -a 
  sysctl -w vm.swappiness=0
  sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab
  touch /etc/kubernetes/scripts/swap.sh
fi

# # 开启IPVS
# if ! [ -e /etc/kubernetes/scripts/ipvs.sh ] ; then 
#   mkdir -p /etc/sysconfig/modules/
#   cat > /etc/sysconfig/modules/ipvs.modules <<EOF
# #!/bin/bash
# /sbin/modprobe -- nf_conntrack_ipv4
# ipvs_modules_dir="/lib/modules/\`uname -r\`/kernel/net/netfilter/ipvs"
# for i in \`ls \$ipvs_modules_dir | sed  -r 's#(.*).ko(.*)#\1#'\`; do
#     /sbin/modinfo -F filename \$i  &> /dev/null
#     if [ \$? -eq 0 ]; then
#         /sbin/modprobe \$i
#     fi
# done
# EOF
#   chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4 -e br_netfilter
#   touch /etc/kubernetes/scripts/ipvs.sh
# fi

if ! [ -e /etc/modules-load.d/k8s.conf ] ; then 
  cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
xt_bpf
EOF

  modprobe overlay
  modprobe br_netfilter
  modprobe xt_bpf

fi

if ! [ -e /etc/sysctl.d/99-kubernetes.conf ] ; then 
  # sysctl params required by setup, params persist across reboots
  cat <<EOF | tee /etc/sysctl.d/99-kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
net.ipv4.ip_unprivileged_port_start = 0
net.ipv4.ip_local_port_range        = 1 65535
net.ipv6.conf.all.forwarding        = 1
net.core.bpf_jit_limit              = 264241152
fs.inotify.max_user_watches         = 524288
fs.inotify.max_user_instances       = 25600
EOF

  # Apply sysctl params without reboot
  sysctl --system
fi
