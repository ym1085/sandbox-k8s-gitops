#!/bin/bash
set -e
echo "==================================="
echo " Kubernetes in Docker (kind) Setup "
echo "==================================="
echo
# 스크립트 파일이 위치한 디렉토리의 절대 경로를 구함
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIND_CONFIG=$(ls "${SCRIPT_DIR}"/*.yaml 2>/dev/null | head -n 1)
if [[ -z $KIND_CONFIG ]]; then
  echo '파일이 존재하지 않습니다.'
  exit 1
fi
echo 'Filename => $KIND_CONFIG'
kind create cluster --config $KIND_CONFIG
kubectl ctx
kubectl get nodes
#kubectl cluster-info --context kind-helm-cluster
#kubectl get nodes
