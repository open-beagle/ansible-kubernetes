#!/bin/bash

sync ; echo 3 > /proc/sys/vm/drop_caches

# 清理 docker 中没有 tag 的镜像（<none>:<none>）
if command -v /opt/bin/docker &> /dev/null; then
  /opt/bin/docker images --filter "dangling=true" -q --no-trunc | xargs -r /opt/bin/docker rmi
fi

# 清理 nerdctl 中没有 tag 的镜像（<none>:<none>）
if command -v /opt/bin/nerdctl &> /dev/null; then
  /opt/bin/nerdctl -n k8s.io images --filter "dangling=true" -q | xargs -r /opt/bin/nerdctl -n k8s.io rmi
fi

# 清理停止超过3个月的容器
THREE_MONTHS_AGO=$(date -d '3 months ago' +%s)

# 清理 nerdctl 中停止超过3个月的容器
if command -v /opt/bin/nerdctl &> /dev/null; then
  /opt/bin/nerdctl -n k8s.io ps -a --filter "status=exited" --format "{{.ID}} {{.CreatedAt}}" | while read container_id created_at; do
    container_timestamp=$(date -d "$created_at" +%s 2>/dev/null || echo 0)
    if [ "$container_timestamp" -lt "$THREE_MONTHS_AGO" ]; then
      /opt/bin/nerdctl -n k8s.io rm "$container_id"
    fi
  done
fi
