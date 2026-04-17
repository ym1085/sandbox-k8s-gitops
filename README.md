# Kubernetes Deployment Lab

## Overview

**[sandbox-ecommerce-api](https://github.com/ym1085/sandbox-ecommerce-api)** 배포 및 운영을 위한 리포지토리입니다.

## Project Structure

```shell
├── argocd/
│   ├── applications/
│   ├── appprojects/
│   └── install/
│       ├── dev/
│       ├── stg
│       └── prod/
├── charts/
│   ├── order-service/
│   └── user-service/
├── script/
│   ├── cluster/
│   ├── gitops/
│   └── infrastructure/
└── helmfile.yaml
```

### Components

| 분류                | 경로            | 내용                                                    |
| :------------------ | :-------------- | :------------------------------------------------------ |
| **ArgoCD Ops**      | `argocd/`       | ArgoCD 설치, AppProjects 및 Application 매니페스트 관리 |
| **Helm Charts**     | `charts/`       | 서비스별 Helm 차트 및 배포 템플릿 정의                  |
| **Automation**      | `script/`       | 클러스터 프로비저닝 및 GitOps 구성 자동화 스크립트      |
| **Helm Management** | `helmfile.yaml` | Helm 릴리스 통합 관리 및 환경별 변수 주입               |

## Prerequisites

- kubectl v1.35.1
- Helm v4.1.1
- Helmfile v1.3.1
- AWS CLI 2.33.28
- Docker v29.2.1
