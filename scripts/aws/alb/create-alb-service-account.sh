#!/bin/bash

# k8s ServiceAccount를 만들고, 그 ServiceAccount와 연결된 IAM Role을 동시에 생성/연결하여
# Pod가 해당 IAM 권한으로 AWS 리소스를 사용할 수 있게 만드는 작업
eksctl create iamserviceaccount \
  --cluster $CLUSTER_NAME \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --region $REGION \
  --approve