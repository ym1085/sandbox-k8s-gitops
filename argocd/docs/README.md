# Argo CD Option Guide

이 문서는 이 저장소에서 사용하는 `Application`과 `AppProject` 옵션을 빠르게 확인하기 위한 문서다.

## 한눈에 보기

```text
Application
├── source       무엇을 배포할지
├── destination  어디에 배포할지
├── project      어떤 권한으로 배포할지
└── syncPolicy   어떻게 동기화할지
        │
        ▼
AppProject
├── sourceRepos               허용된 저장소
├── destinations              허용된 클러스터와 namespace
└── clusterResourceWhitelist  허용된 cluster-scoped 리소스
```

실제 연결 예시:

```text
applications/dev/apps/order-service.yaml
  spec.project: order-dev
                │
                ▼
projects/dev/apps/order.yaml
  metadata.name: order-dev
```

## Application 옵션

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: order-service-dev
  namespace: argocd
spec:
  project: order-dev
  source:
    repoURL: https://github.com/ym1085/sandbox-k8s-gitops.git
    targetRevision: dev
    path: charts/order-service
    helm:
      valueFiles:
        - values-dev.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: order-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
      - ServerSideDiff=true
      - PruneLast=true
```

| 옵션                    | 의미                                        | 현재 예시                        |
| ----------------------- | ------------------------------------------- | -------------------------------- |
| `metadata.name`         | Argo CD Application 이름                    | `order-service-dev`             |
| `metadata.namespace`    | Application CR이 생성되는 namespace         | `argocd`                         |
| `spec.project`          | 사용할 AppProject 이름                      | `order-dev`                      |
| `source.repoURL`        | Git 또는 Helm repository                    | `sandbox-k8s-gitops.git`         |
| `source.targetRevision` | Git branch/tag/SHA 또는 Helm chart 버전     | `dev`, `stg`, `master`, `4.11.0` |
| `source.path`           | Git repository 안의 chart/manifest 경로     | `charts/order-service`           |
| `source.chart`          | 외부 Helm repository의 chart 이름           | `ingress-nginx`                  |
| `helm.valueFiles`       | 기본 values 위에 병합할 환경 values         | `values-dev.yaml`                |
| `helm.values`           | Application 안에 직접 작성하는 Helm values  | ingress-nginx 설정               |
| `destination.server`    | 대상 Kubernetes API server                  | 현재 클러스터                    |
| `destination.namespace` | 리소스를 배포할 namespace                   | `order-dev`                      |
| `automated`             | Git 변경을 자동으로 sync                    | dev/stg만 사용                   |
| `prune`                 | Git에서 삭제된 리소스를 클러스터에서도 삭제 | dev/stg `true`                   |
| `selfHeal`              | 수동 변경된 클러스터 상태를 Git 상태로 복구 | dev/stg `true`                   |
| `CreateNamespace=true`  | destination namespace가 없으면 생성         | 모든 Application                 |
| `ServerSideApply=true`  | Kubernetes Server-Side Apply 사용           | 모든 Application                 |
| `PruneLast=true`        | sync 마지막 단계에서 리소스 삭제            | 모든 Application                 |

> `ServerSideDiff`는 sync option이 아니라 비교 전략이다. 공식적인 Application 단위 설정은 `metadata.annotations[argocd.argoproj.io/compare-options]: ServerSideDiff=true`다. 현재 매니페스트는 기존 설정을 유지하고 있으며 별도 변경으로 검토해야 한다.

## Image Updater 옵션

```yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: "order-api=youngmin1085/order-service"
    argocd-image-updater.argoproj.io/order-api.update-strategy: "newest-build"
    argocd-image-updater.argoproj.io/order-api.allow-tags: "regexp:^dev-[a-f0-9]{7}$"
    argocd-image-updater.argoproj.io/order-api.helm.image-name: deployment.containers[0].image
    argocd-image-updater.argoproj.io/order-api.helm.image-tag: deployment.containers[0].tag
    argocd-image-updater.argoproj.io/write-back-method: git
```

| 옵션                      | 의미                                                     |
| ------------------------- | -------------------------------------------------------- |
| `image-list`              | 추적할 이미지와 내부 alias 정의                          |
| `<alias>.update-strategy` | tag 선택 전략: dev/stg는 `newest-build`, prod는 `semver` |
| `<alias>.allow-tags`      | 허용할 tag를 정규식으로 제한                             |
| `<alias>.helm.image-name` | 이미지 repository를 기록할 Helm values 경로              |
| `<alias>.helm.image-tag`  | 이미지 tag를 기록할 Helm values 경로                     |
| `write-back-method: git`  | 변경 결과를 Git의 `.argocd-source-*` 파일에 기록         |

## AppProject 옵션

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: order-dev
  namespace: argocd
spec:
  description: "Dev order service (주문팀)"
  sourceRepos:
    - https://github.com/ym1085/sandbox-k8s-gitops.git
  destinations:
    - namespace: order-dev
      server: https://kubernetes.default.svc
```

> 앱 워크로드 AppProject(`order-{env}`, `user-{env}`)에는 `clusterResourceWhitelist`가 없다. cluster-scoped 리소스가 필요한 infra(`infra-{env}`) AppProject만 `clusterResourceWhitelist`를 가진다.

| 옵션                               | 의미                                         | 위반 시 결과                        |
| ---------------------------------- | -------------------------------------------- | ----------------------------------- |
| `metadata.name`                    | `Application.spec.project`에서 참조하는 이름 | 존재하지 않으면 Application 오류    |
| `metadata.namespace`               | AppProject CR이 생성되는 namespace           | Application과 같은 `argocd` 사용    |
| `description`                      | Project 용도 설명                            | 배포 동작에는 영향 없음             |
| `sourceRepos`                      | Application이 사용할 수 있는 repository      | 목록에 없으면 배포 거부             |
| `destinations[].server`            | 배포 가능한 Kubernetes cluster               | 허용되지 않은 cluster면 배포 거부   |
| `destinations[].namespace`         | 배포 가능한 namespace                        | 허용되지 않은 namespace면 배포 거부 |
| `clusterResourceWhitelist[].group` | 허용할 cluster-scoped API group              | 허용되지 않은 group이면 배포 거부   |
| `clusterResourceWhitelist[].kind`  | 허용할 cluster-scoped resource kind          | 허용되지 않은 kind면 배포 거부      |

현재 `group: "*"`, `kind: "*"`는 모든 cluster-scoped 리소스를 허용한다. 운영 환경에서는 필요한 kind만 허용하는 최소 권한 설정을 별도로 검토해야 한다.

## 현재 Project 연결

| 환경 | Application   | AppProject       | 허용 namespace                                |
| ---- | ------------- | ---------------- | --------------------------------------------- |
| dev  | order         | `order-dev`   | `order-dev`         |
| dev  | user          | `user-dev`    | `user-dev`          |
| dev  | ingress-nginx | `infra-dev`   | `ingress-nginx-dev` |
| stg  | order         | `order-stg`   | `order-stg`         |
| stg  | user          | `user-stg`    | `user-stg`          |
| stg  | ingress-nginx | `infra-stg`   | `ingress-nginx-stg` |
| prod | order         | `order-prod`  | `order-prod`        |
| prod | user          | `user-prod`   | `user-prod`         |
| prod | ingress-nginx | `infra-prod`  | `ingress-nginx-prod`|

## 배포 판단 순서

```text
1. Application.source       repository, revision, chart 확인
2. Application.destination  cluster, namespace 확인
3. Application.project      AppProject 연결 확인
4. AppProject               source와 destination 허용 여부 확인
5. Application.syncPolicy   자동/수동 동기화 방식 확인
```
