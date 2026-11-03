#!/usr/bin/env bash
set -euo pipefail

minikube start \
  --profile=minikube \
  --driver=docker \
  --cpus=2 \
  --memory=2560 \
  --kubernetes-version=v1.37.0 \
  --ports=0.0.0.0:30080:30080 \
  --wait=apiserver

minikube --profile=minikube ssh -- \
  "printf 'nameserver 1.1.1.1\nnameserver 1.0.0.1\n' | sudo tee /etc/resolv.conf >/dev/null"

kubectl --context=minikube wait \
  --for=condition=Ready node/minikube \
  --timeout=300s
