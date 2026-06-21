# Kubernetes Deployment Lab

## Overview

Kubernetes 배포 및 운영을 위한 GitOps 기반 인프라 리포지토리입니다. ArgoCD를 통해 애플리케이션 배포를 관리하고, Helm 차트로 서비스별 릴리스와 환경(dev/stg/prod) 구성을 일관되게 운영합니다.

## Project Structure

```shell
├── argocd/
│   ├── bootstrap/
│   │   ├── common/
│   │   ├── dev/
│   │   ├── stg/
│   │   └── prod/
│   ├── applications/
│   │   ├── dev/
│   │   ├── stg/
│   │   └── prod/
│   └── projects/
│       ├── dev/
│       ├── stg/
│       └── prod/
├── charts/
│   ├── order-service/
│   └── user-service/
└── scripts/
    ├── aws/
    ├── gitops/
    └── k8s/
```

### Components

| 분류                | 경로            | 내용                                                    |
| :------------------ | :-------------- | :------------------------------------------------------ |
| **ArgoCD Ops**      | `argocd/`       | ArgoCD 설치, AppProjects 및 Application 매니페스트 관리 |
| **Helm Charts**     | `charts/`       | 서비스별 Helm 차트 및 배포 템플릿 정의                  |
| **Automation**      | `scripts/`      | 클러스터 프로비저닝 및 GitOps 구성 자동화 스크립트      |

Argo CD `Application`과 `AppProject` 옵션은 [Argo CD Manifest Option Reference](argocd/docs/README.md)에서 확인할 수 있습니다.

## Tech Stack

| 분류             | 기술                          |
| ---------------- | ----------------------------- |
| Orchestration    | Kubernetes v1.35.1            |
| GitOps           | Argo CD                       |
| Package Manager  | Helm v4.1.1                   |
| Ingress          | ingress-nginx 4.11.0          |
| Cloud / CLI      | AWS CLI 2.33.28               |
| Container        | Docker v29.2.1                |

## Argo CD Setup Order

환경을 처음 구성하거나 기존 환경을 새 Project 구조로 전환할 때 다음 순서를 사용합니다.

1. `scripts/gitops/argocd/bootstrap-argocd.sh`
2. `scripts/gitops/argocd/setup-appprojects.sh`
3. `scripts/gitops/argocd/setup-applications.sh`

기존 환경을 전환한 뒤 Application이 새 `order-{env}`, `user-{env}`, `infra-{env}` Project를 참조하는지 확인하고 기존 Project를 삭제합니다.
