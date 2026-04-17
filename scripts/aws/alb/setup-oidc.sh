#!/bin/bash

# EKS Cluster의 OIDC Issuer URL을 AWS IAM의 OIDC Provider로 등록하여
# ServiceAccount가 IAM Role을 연결/사용 할 수 있도록 신뢰 관계를 설정하는 작업
eksctl utils associate-iam-oidc-provider \
--cluster $CLUSTER_NAME \
--region $DEFAULT_REGION \
--approve