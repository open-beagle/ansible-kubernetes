# Setup

```bash
# 1. Install
helm install \
cilium \
/etc/kubernetes/charts/beagle-cilium-1.14.14.tgz \
--namespace kube-system \
-f /etc/kubernetes/charts/beagle-cilium-1.14.14.yaml

# 2. Upgrade
helm upgrade \
cilium \
/etc/kubernetes/charts/beagle-cilium-1.14.14.tgz \
--namespace kube-system \
-f /etc/kubernetes/charts/beagle-cilium-1.14.14.yaml

# 3. Uninstall
helm uninstall \
cilium \
--namespace kube-system
```
