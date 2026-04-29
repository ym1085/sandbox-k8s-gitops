# Kubernetes Deployment Lab

## Overview

Kubernetes 배포 및 운영을 위한 GitOps 기반 인프라 리포지토리입니다. ArgoCD를 통해 애플리케이션 배포를 관리하고, Helm/Helmfile을 사용하여 서비스별 릴리스와 환경(dev/stg/prod) 구성을 일관되게 운영합니다.

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
