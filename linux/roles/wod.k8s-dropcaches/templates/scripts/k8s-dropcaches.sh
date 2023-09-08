#!/bin/bash

sync ; echo 3 > /proc/sys/vm/drop_caches

/opt/bin/docker system prune -a -f
/opt/bin/nerdctl -n k8s.io system prune -a -f
