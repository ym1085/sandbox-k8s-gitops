# AGENTS.md

## 프로젝트 성격

이 저장소는 `order-service`, `user-service`, `ingress-nginx`를 `dev/stg/prod` 환경에 배포하는 Kubernetes GitOps 저장소다.  
에이전트는 애플리케이션 코드가 아니라 Argo CD 선언, Helm 차트, 환경별 values, 운영 스크립트를 다룬다.

배포 판단 기준은 항상 `argocd/{env}/applications` 이다.

## 수정 위치 규칙

- 실제 배포 경로와 동기화 기준은 `argocd/{env}/applications`에서 확인한다.
- 배포 허용 범위와 프로젝트 정책은 `argocd/{env}/appprojects`에서 관리한다.
- 서비스 스펙 변경은 `charts/order-service`, `charts/user-service`에서 한다.
- `ingress-nginx`는 로컬 chart가 아니라 Argo CD가 외부 Helm repo에서 직접 설치한다.
- 환경별 차이는 반드시 `values-{env}.yaml`에 둔다. 공통값만 `values.yaml`에 둔다.
- `argocd/{env}/install`는 Argo CD 자체 설치 설정이다. 애플리케이션 배포 설정과 혼동하지 않는다.

## 아키텍처 규칙

- CRITICAL: 실제 배포 설정은 항상 `argocd/{env}/applications`를 먼저 본다.
- CRITICAL: 어떤 환경에 무엇이 배포되는지는 항상 Argo CD `Application` 기준으로 판단한다.
- CRITICAL: `order-service`와 `user-service`는 구조가 유사하지만 완전히 동일하지 않다. 한쪽만 보고 공통 리팩터링하지 않는다.
- CRITICAL: `dev`, `stg`, `prod`는 같은 방식으로 운영되지 않는다. 환경별 Argo CD 설정 차이를 먼저 확인한다.
- 환경 확장은 `values.yaml -> values-{env}.yaml` 병합을 전제로 한다. 환경별 예외를 base values에 넣지 않는다.
- 네임스페이스 규칙은 `{env}-order-ns`, `{env}-user-ns`, `{env}-ingress-nginx-ns`를 따른다.
- ingress class는 환경별로 `nginx-dev`, `nginx-stg`, `nginx-prod`를 사용한다.

## CRITICAL 주의사항

- CRITICAL: 로컬 Git remote 및 Argo CD `Application.spec.source.repoURL`은 모두 `https://github.com/ym1085/sandbox-k8s-gitops.git`를 가리킨다.
- CRITICAL: 로컬 변경이 곧바로 실제 동기화 대상이라고 가정하지 않는다.
- CRITICAL: chart 수정만으로 배포가 바뀐다고 보지 않는다. 어떤 `Application`이 어떤 `repoURL`, `targetRevision`, `path`, `valueFiles`를 바라보는지 먼저 확인한다.
- CRITICAL: `targetRevision`은 환경 계약의 일부다. 의도 없이 바꾸지 않는다.
- CRITICAL: `charts/user-service/templates/deployment.yaml`은 `env` 렌더링이 `resources` 조건 내부에 묶여 있다. `order-service`와 동일 동작이라고 가정하면 틀릴 수 있다.
- CRITICAL: `prod` Application은 `dev/stg`와 달리 `automated.prune/selfHeal`이 없다. 같은 자동 동기화 동작을 기대하면 안 된다.
- CRITICAL: `.argocd-source-*` 파일은 Argo CD Image Updater write-back 산출물이다. 수동 관리 파일처럼 다루지 않는다.

## 작업 순서

1. 먼저 `argocd/{env}/applications`에서 실제 동기화 대상 `repoURL`, `targetRevision`, `path`, `valueFiles`를 확인한다.
2. 환경 공통 변경인지, 특정 환경 변경인지 먼저 결정한다.
3. 서비스 차트 수정 시 `order-service`와 `user-service` 차이를 비교한다.
4. 이름, namespace, ingress backend, port 계약이 깨지지 않는지 확인한다.
5. 필요하면 `helm template`로 렌더링을 확인하되, 배포 기준은 Argo CD 선언으로 본다.

## 수정 금지 또는 고위험 변경

명시적 요청 없이 아래 변경을 하지 않는다.

- namespace rename
- release/service naming 규칙 변경
- ingress backend naming 규칙 변경
- `targetRevision` 변경
- 환경별 NodePort 체계 변경
- `AppProject.spec.destinations`와 실제 배포 namespace 불일치 유발

## 검증 명령

각 차트를 환경별 values와 함께 직접 렌더링해 확인한다.

```bash
helm template order-service ./charts/order-service \
  -f ./charts/order-service/values.yaml \
  -f ./charts/order-service/values-dev.yaml

helm template user-service ./charts/user-service \
  -f ./charts/user-service/values.yaml \
  -f ./charts/user-service/values-dev.yaml
```

## 환경별 운영 포인트

- `dev` Application은 `targetRevision: dev`를 본다.
- `stg` Application은 `targetRevision: stg`를 본다.
- `prod` Application은 `targetRevision: master`를 본다.
- `dev/stg` image updater 전략은 `newest-build` + 환경별 태그 정규식이다.
- `prod` image updater 전략은 `semver`다.
- `AppProject`는 환경별 namespace와 `sourceRepos`를 제한한다. 새 저장소나 namespace를 쓰려면 `Application`만이 아니라 `AppProject`도 같이 수정해야 한다.

## 빠른 판단 기준

- 배포 흐름이 이상하면 `charts/`보다 먼저 `argocd/{env}/applications`를 본다.
- 환경 문제가 나면 파일 하나가 아니라 환경 슬라이스 전체를 본다.
- 이 저장소에서 가장 흔한 실수는 로직 문제보다 `env`, `namespace`, `branch`, `service name`, `port` 불일치다.
