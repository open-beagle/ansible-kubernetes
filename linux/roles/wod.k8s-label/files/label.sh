#!/bin/bash 

set -ex

/opt/bin/kubectl label node $K8S_HOST node-role.kubernetes.io/master="true" --overwrite