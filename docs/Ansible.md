# ansible

## hosts.ini

hosts.ini 如何准备

```ini
[master]
beagle-01 ansible_ssh_host=192.168.1.201 ansible_ssh_port=22 ansible_ssh_user=root

[node]
beagle-02 ansible_ssh_host=192.168.1.202 ansible_ssh_port=22 ansible_ssh_user=root
beagle-03 ansible_ssh_host=192.168.1.203 ansible_ssh_port=22 ansible_ssh_user=root
```

### master分组

k8s集群的控制节点，最大支持3个控制节点

### node分组

k8s集群的计算节点，计算节点可配置多个

### 免密登录

默认ansible脚本需要sudo权限，建议配置root账户进行免密登录

- 登录所有安装的服务器节点，执行以下命令

```bash
mkdir -p /root/.ssh && \
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDCJNFRbNc0SsHa/+mWB71z7SLPH9rQpwEqGbRo7q466a97h3bejNav9wc9AKmepHPfRw7DJfSmWO3lGBya0QkXMYXVvtfcWPvZZDlar5JK/ZsC8HGOpwVLdd1uUfyPu2qM0sjRNA/Ty8PDMkS5dSyZAJNlxUAILRpepkYoT8jhrw== ansible@docker' > /root/.ssh/authorized_keys && \
chmod 600 /root/.ssh/authorized_keys
```

### 密码登录

```ini
[master]
beagle-01 ansible_ssh_host=192.168.1.201 ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass=passwd

[node]
beagle-02 ansible_ssh_host=192.168.1.202 ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass=passwd
beagle-03 ansible_ssh_host=192.168.1.203 ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass=passwd
```

### 非ROOT登录

```ini
[master]
beagle-01 ansible_ssh_host=192.168.1.201 ansible_ssh_port=22 ansible_ssh_user=core ansible_ssh_pass=passwd ansible_sudo_pass=passwd ansible_become=true

[node]
beagle-02 ansible_ssh_host=192.168.1.202 ansible_ssh_port=22 ansible_ssh_user=core ansible_ssh_pass=passwd ansible_sudo_pass=passwd ansible_become=true
beagle-03 ansible_ssh_host=192.168.1.203 ansible_ssh_port=22 ansible_ssh_user=core ansible_ssh_pass=passwd ansible_sudo_pass=passwd ansible_become=true
```
