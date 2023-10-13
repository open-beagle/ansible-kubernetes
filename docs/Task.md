# 运行维护任务Task

## 集群节点-修改IP

### 控制节点Master-修改IP

1. 修改hosts文件

- beagle-01 , ETCD使用主机名作为节点名称，使用Hosts来解析节点主机对应的IP

```bash
# 修改hosts文件
# /etc/hosts
192.168.1.201 beagle-01
192.168.1.202 beagle-02
192.168.1.203 beagle-03
```

### 计算节点Worker-修改IP

1. 修改负载均衡Envoy配置文件

改完后重启k8s-envoy服务，建议整个计算节点重启

- clusters.kubernetes.address , 控制节点外部IP使用的域名
- clusters.registry.address , 镜像服务器IP

```bash
# 修改hosts文件
# /etc/kubernetes/services/k8s-envoy/envoy.yaml
static_resources:
  listeners:
    - name: https-kubernetes
      address:
        socket_address:
          address: 0.0.0.0
          port_value: 6443
      ....
    - name: https-registry
      address:
        socket_address:
          address: 0.0.0.0
          port_value: 6444
      ....
  clusters:
    - name: kubernetes
      connect_timeout: 30s
      type: STRICT_DNS
      dns_lookup_family: V4_ONLY
      load_assignment:
        cluster_name: kubernetes
        endpoints:
          - lb_endpoints:
              - endpoint:
                  health_check_config:
                    port_value: 6443
                  address:
                    socket_address:
                      address: 192.168.1.201
                      port_value: 6443
    - name: registry
      connect_timeout: 30s
      type: STRICT_DNS
      dns_lookup_family: V4_ONLY
      load_assignment:
        cluster_name: registry
        endpoints:
          - lb_endpoints:
              - endpoint:
                  health_check_config:
                    port_value: 6444
                  address:
                    socket_address:
                      address: 192.168.1.201
                      port_value: 6444
```

## 集群升级

### 更新镜像包

某个特定的版本如v1.24.12，镜像包升级了，或者安装结构发生了调整，则使用以下命令进行升级。

```bash
# 删除缓存的镜像包tgz
rm -rf \
/etc/kubernetes/ansible/ansible-docker-v1.24.12-amd64.tgz \
/etc/kubernetes/ansible/ansible-kubernetes-v1.24.12-amd64.tgz \
/etc/kubernetes/ansible/ansible-kubernetes-images-v1.24.12-amd64.tgz \
/etc/kubernetes/ansible/ansible-kubernetes-v1.24.12.sh

# 重新跑离线安装脚本即可
curl -sfL https://cache.wodcloud.com/kubernetes/k8s/ansible/v1.24/amd64/ansible-kubernetes-v1.24.12.sh > /etc/kubernetes/ansible/ansible-kubernetes-v1.24.12.sh && \
bash /etc/kubernetes/ansible/ansible-kubernetes-v1.24.12.sh
```
