# Setup

```bash
# 1. Package
helm package .

# 2. Install
helm install \
cilium \
/etc/kubernetes/charts/beagle-cilium-1.11.18.tgz \
--namespace kube-system \
-f /etc/kubernetes/charts/beagle-cilium-1.11.18.yaml

# 3. Upgrade
helm upgrade \
cilium \
/etc/kubernetes/charts/beagle-cilium-1.11.18.tgz \
--namespace kube-system \
-f /etc/kubernetes/charts/beagle-cilium-1.11.18.yaml

# 4. Uninstall
helm uninstall \
cilium \
--namespace kube-system

# 5. Template
helm template \
cilium \
/etc/kubernetes/charts/beagle-cilium-1.11.18.tgz \
--namespace kube-system \
-f /etc/kubernetes/charts/beagle-cilium-1.11.18.yaml >  /etc/kubernetes/charts/beagle-cilium-dist.yaml
```
