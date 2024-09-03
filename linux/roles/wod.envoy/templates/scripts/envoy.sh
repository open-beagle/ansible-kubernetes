#!/bin/bash

set -e

if [-e /etc/systemd/system/k8s-envoy.service ]; then
  mkdir -p /etc/kubernetes/services

  system disable k8s-envoy.service
  system stop k8s-envoy.service
  mv k8s-envoy.service /etc/kubernetes/services/k8s-envoy.service
fi
