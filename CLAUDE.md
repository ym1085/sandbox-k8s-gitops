# CLUADE.md

## 프로젝트 성격

이 저장소는 `order-service`, `user-service`, `ingress-nginx`를 `dev/stg/prod` 환경에 배포하는 Kubernetes GitOps 리포지토리다. 배포 판단은 항상 `Argo CD Application` 기준으로 맞춘다.

## 수정 위치 규칙

- 실제 배포 경로와 동기화 기준은 `argocd/{env}/applications`에서 확인한다.
- 배포 허용 범위와 프로젝트 정책은 `argocd/{env}/appprojects`에서 관리한다.
- 서비스 스펙 변경은 `charts/order-service`, `charts/user-service`에서 한다.
- `ingress-nginx`는 로컬 chart가 아니라 Argo CD가 외부 Helm repo에서 직접 설치한다.
- 환경별 차이는 반드시 `values-{env}.yaml`에 둔다. 공통값만 `values.yaml`에 둔다.

## 아키텍처 규칙

- CRITICAL: 실제 배포 설정은 항상 `argocd/{env}/applications`를 먼저 본다.
- CRITICAL: 어떤 환경에 무엇이 배포되는지는 항상 Argo CD Application 기준으로 판단한다.
- CRITICAL: `order-service`와 `user-service`는 구조가 유사하지만 완전히 동일하지 않다. 한쪽만 보고 공통 리팩터링하지 않는다.
- CRITICAL: `dev`, `stg`, `prod`는 같은 방식으로 운영되지 않는다. 환경별 Argo CD 설정 차이를 먼저 확인한다.
- 환경 확장은 `values.yaml -> values-{env}.yaml` 병합을 전제로 한다. 환경별 예외를 base values에 넣지 않는다.
- 네임스페이스 규칙은 `{env}-order-ns`, `{env}-user-ns`, `{env}-ingress-nginx-ns`를 따른다.
- ingress class는 환경별로 `nginx-dev`, `nginx-stg`, `nginx-prod`를 사용한다.

## CRITICAL 주의사항

- CRITICAL: 로컬 Git remote 및 Argo CD Application의 `repoURL`은 모두 `sandbox-k8s-gitops`(`https://github.com/ym1085/sandbox-k8s-gitops.git`)를 가리킨다.
- CRITICAL: 로컬 변경사항이 곧바로 Argo CD 동기화 대상이라고 가정하면 안 된다.
- CRITICAL: chart 수정만으로 배포가 바뀐다고 보지 않는다. 해당 chart를 어떤 Argo CD Application이 어떤 `repoURL`, `targetRevision`, `values file`로 바라보는지 먼저 확인한다.
- CRITICAL: `charts/user-service/templates/deployment.yaml`은 `env` 렌더링이 `resources` 조건 내부에 묶여 있다. `order-service`와 동일 동작이라고 가정하면 틀릴 수 있다.
- CRITICAL: `prod` Application은 `dev/stg`와 달리 `automated.prune/selfHeal`이 없다. 같은 자동 동기화 동작을 기대하면 안 된다.

## 작업 순서

1. 먼저 `argocd/{env}/applications`에서 실제 동기화 대상 `repoURL`, `targetRevision`, `path`, `valueFiles`를 확인한다.
2. 환경 공통 변경인지, 특정 환경 변경인지 먼저 결정한다.
3. 서비스 차트 수정 시 `order-service`와 `user-service` 차이를 비교한다.
4. 필요하면 `helm template`로 렌더링을 확인하되, 배포 기준은 Argo CD 선언으로 본다.

## 환경별 운영 포인트

- `dev` Application은 `targetRevision: dev`를 본다.
- `stg` Application은 `targetRevision: stg`를 본다.
- `prod` Application은 `targetRevision: master`를 본다.
- `dev/stg` image updater 전략은 `newest-build` + 환경별 태그 정규식이다.
- `prod` image updater 전략은 `semver`다.
- `AppProject`는 환경별 namespace와 `sourceRepos`를 제한한다. 새 저장소나 namespace를 쓰려면 Application만이 아니라 AppProject도 같이 수정해야 한다.

## 검증 명령

```bash
helm template order-service ./charts/order-service -f ./charts/order-service/values.yaml -f ./charts/order-service/values-dev.yaml
helm template user-service ./charts/user-service -f ./charts/user-service/values.yaml -f ./charts/user-service/values-dev.yaml
```
