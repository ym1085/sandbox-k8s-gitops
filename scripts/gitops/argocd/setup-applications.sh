#!/bin/bash
set -e
echo "======================================"
echo "Installing ArgoCD Applications on kind k8s cluster"
echo "======================================"
echo "Select environment"
echo "1: dev, 2:stg, 3:prod"
read -p "Enter number: " ENV_NUM
case "${ENV_NUM}" in
    1) PROFILE="dev";;
    2) PROFILE="stg";;
    3) PROFILE="prod";;
    *) 
      echo "Invalid input. Please enter 1, 2, or 3." 
      exit 1;;
esac

####################################
# 경로 계산
####################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/../../.."
echo -e "ROOT_DIR: $ROOT_DIR\n"

####################################
# Applications 생성
####################################
echo "Creating Applications..."
kubectl apply -f "$ROOT_DIR/argocd/applications/${PROFILE}/"
echo "Applications created successfully"