# UnionTech-v20

统信v20操作系统安装记录。

## 前置条件

### 关闭防火墙

安装之前，关闭防火墙，重启服务器

```bash
systemctl stop firewalld && \
systemctl disable firewalld && \
reboot
```
