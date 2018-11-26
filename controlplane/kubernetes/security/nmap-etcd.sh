#!/bin/bash

set -euxo pipefail

ETCD_IP_OR_CIDR=10.0.1.1
NAME=alpine-base-${RANDOM}

kubectl run -i ${NAME} --image=sublimino/alpine-base --restart=Never --generator=run-pod/v1 --overrides '{"apiVersion":"v1", "spec":{"containers":  [{"name":"'${NAME}'", "image": "sublimino/alpine-base", "command": ["/bin/bash","-c","--"],"args": ["nmap --open -T4 -v -Pn -p 2379,4001 '${ETCD_IP_OR_CIDR}' -oX -"], "securityContext": {"privileged":false, "runAsUser": 0}}]}}'

if kubectl logs "${NAME}" | xmlstarlet sel --noblanks -t -v '/nmaprun/host/ports/port/state/@state'; then
  echo "etcd port found"
  false
else
  echo "etcd ports not found"
  true
fi
