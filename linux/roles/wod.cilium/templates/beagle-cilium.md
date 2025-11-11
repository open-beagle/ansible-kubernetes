# Setup

```bash
# 1. Install
helm install \
cilium \
/etc/kubernetes/charts/beagle-cilium-1.18.3.tgz \
--namespace kube-system \
-f /etc/kubernetes/charts/beagle-cilium-1.18.3.yaml

# 2. Upgrade
helm upgrade \
cilium \
/etc/kubernetes/charts/beagle-cilium-1.18.3.tgz \
--namespace kube-system \
-f /etc/kubernetes/charts/beagle-cilium-1.18.3.yaml

# 3. Uninstall
helm uninstall \
cilium \
--namespace kube-system
```
