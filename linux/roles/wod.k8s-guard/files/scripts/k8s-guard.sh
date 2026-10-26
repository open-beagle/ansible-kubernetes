#!/bin/bash

set -e

export PATH=/usr/sbin:/usr/bin:/sbin:/bin:$PATH

case "$1" in
start)
  nft -f /etc/kubernetes/guard/guard.nft
  ;;
stop)
  nft delete table inet beagle_guard 2>/dev/null || true
  ;;
*)
  echo "Usage: $0 {start|stop}"
  exit 1
  ;;
esac
