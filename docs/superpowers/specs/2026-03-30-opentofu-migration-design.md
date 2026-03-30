# OpenTofu Migration Design

zzizily.com 도메인 Cloudflare Terraform → OpenTofu 마이그레이션

## 개요

Terraform CLI를 OpenTofu CLI로 마이그레이션하고, 상태 백엔드를 Terraform Cloud(Remote)에서 Cloudflare R2(S3 호환)로 전환. Provider 버전(`~> 3.20.0`)은 유지, CI/CD GitHub Actions 워크플로우 함께 업데이트.

## 변경 범위

| 파일 | 변경 내용 |
|------|----------|
| `domain/root/backend.tf` | `remote` → `s3`(R2) |
| `domain/root/version.tf` | `required_version` 추가, `required_providers` 유지 |
| `domain/root/variables.tf` | `cloudflare_email` 제거 (미사용) |
| `.github/workflows/terraform.yml` | `hashicorp/setup-terraform` → `opentofu/setup-opentofu`, `terraform` → `tofu` 교체 |
| `.gitignore` | `.terraform.lock.hcl` 추가 |
| GitHub Secrets | `TF_API_TOKEN` 삭제, R2/Cloudflare 시크릿 추가 |

## 변경 상세

### 1. `backend.tf` - 상태 백엔드 교체

**기존 (삭제):**
```hcl
terraform {
  backend "remote" {
    organization = "ZZiZiLY"
    workspaces {
      name = "cloudflare-domain-zzizily"
    }
  }
}
```

**신규:**
```hcl
terraform {
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "cloudflare-domain-zzizily/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    use_lockfile                = true

    endpoints = {
      s3 = "https://e0924c382d21ac0f10aee606b82687ce.r2.cloudflarestorage.com"
    }
  }
}
```

> **설정 설명**:
> - `endpoints = { s3 = "..." }`: OpenTofu S3 backend는 `endpoint` 단일 속성이 아닌 `endpoints` 블록 사용
> - `use_path_style = true`: R2는 path-style 요청 필요
> - `skip_region_validation = true`: `region = "auto"`는 AWS 유효 리전이 아니므로 검증 스킵
> - `skip_requesting_account_id = true`: R2에 STS API가 없으므로 account ID 요청 스킵
> - `skip_s3_checksum = true`: R2는 S3 checksum 검증 미지원
> - `use_lockfile = true`: OpenTofu 1.8+ lockfile 기반 state locking (DynamoDB 불필요)
> - credentials는 `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` 환경 변수로 전달

### 2. `version.tf` - 버전 정보 업데이트

**기존:**
```hcl
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.20.0"
    }
  }
}
```

**신규:**
```hcl
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.20.0"
    }
  }
}
```

> OpenTofu 1.8+ 필요 (`use_lockfile` 지원). Provider source는 Terraform Registry 그대로 사용.

### 3. `.github/workflows/terraform.yml` - CI/CD 업데이트

**기존:**
- `hashicorp/setup-terraform@v1`
- `actions/checkout@v2`, `actions/github-script@0.9.0` (구버전)
- `terraform fmt/init/validate/plan/apply` 명령어
- `TF_API_TOKEN` 시크릿 (Terraform Cloud)
- `TF_LOG: TRACE` 전역 설정

**신규:**
```yaml
name: "OpenTofu"

on:
  push:
    branches:
      - develop
  pull_request:

jobs:
  opentofu:
    name: "OpenTofu"
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup OpenTofu
        uses: opentofu/setup-opentofu@v1
        with:
          tofu_version: "1.9.0"

      - name: tofu fmt
        id: fmt
        run: tofu fmt -check
        working-directory: domain/root

      - name: tofu init
        id: init
        run: tofu init
        working-directory: domain/root
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_cloudflare_api_token: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          TF_VAR_cloudflare_zone_id: ${{ secrets.CLOUDFLARE_ZONE_ID }}
          TF_VAR_cloudflare_domain: ${{ secrets.CLOUDFLARE_DOMAIN }}

      - name: tofu validate
        id: validate
        run: tofu validate -no-color
        working-directory: domain/root
        env:
          TF_VAR_cloudflare_api_token: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          TF_VAR_cloudflare_zone_id: ${{ secrets.CLOUDFLARE_ZONE_ID }}
          TF_VAR_cloudflare_domain: ${{ secrets.CLOUDFLARE_DOMAIN }}

      - name: tofu plan
        id: plan
        if: github.event_name == 'pull_request'
        run: tofu plan -no-color
        working-directory: domain/root
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_cloudflare_api_token: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          TF_VAR_cloudflare_zone_id: ${{ secrets.CLOUDFLARE_ZONE_ID }}
          TF_VAR_cloudflare_domain: ${{ secrets.CLOUDFLARE_DOMAIN }}
        continue-on-error: true

      - uses: actions/github-script@v7
        if: github.event_name == 'pull_request'
        env:
          PLAN: "opentofu\n${{ steps.plan.outputs.stdout }}"
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `#### OpenTofu Format and Style 🖌\`${{ steps.fmt.outcome }}\`
            #### OpenTofu Initialization ⚙️\`${{ steps.init.outcome }}\`
            #### OpenTofu Validation 🤖\`${{ steps.validate.outcome }}\`
            #### OpenTofu Plan 📖\`${{ steps.plan.outcome }}\`
            <details><summary>Show Plan</summary>
            \`\`\`\n
            ${process.env.PLAN}
            \`\`\`
            </details>
            *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
            github.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })

      - name: Plan Status
        if: steps.plan.outcome == 'failure'
        run: exit 1

      - name: tofu apply
        if: github.ref == 'refs/heads/develop' && github.event_name == 'push'
        run: tofu apply -auto-approve
        working-directory: domain/root
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_cloudflare_api_token: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          TF_VAR_cloudflare_zone_id: ${{ secrets.CLOUDFLARE_ZONE_ID }}
          TF_VAR_cloudflare_domain: ${{ secrets.CLOUDFLARE_DOMAIN }}
```

**GitHub Secrets 추가:**
- `AWS_ACCESS_KEY_ID`: R2 API Token (Access Key ID)
- `AWS_SECRET_ACCESS_KEY`: R2 API Token (Secret Access Key)
- `CLOUDFLARE_API_TOKEN`: 기존 Cloudflare API Token
- `CLOUDFLARE_ZONE_ID`: 기존 Cloudflare Zone ID
- `CLOUDFLARE_DOMAIN`: 도메인 이름 (zzizily.com)

> **기존 Secret 삭제:** `TF_API_TOKEN` (Terraform Cloud용)
> **변경 사항:** `TF_LOG: TRACE` 제거 (운영 환경에서 민감 정보 노출 위험). Action 버전 업데이트 (`checkout@v2→v4`, `github-script@0.9.0→v7`). `tofu fmt`에 `-check` 추가 (CI에서 포맷 검증만).

### 4. `variables.tf` - 미사용 변수 제거

`cloudflare_email` variable 제거 (`provider.tf`에서 이미 주석 처리됨). 나머지 변수는 유지.

### 5. `.terraform.lock.hcl` - 삭제 후 .gitignore 추가

- 기존 `domain/root/.terraform.lock.hcl` 삭제
- `.gitignore`에 `.terraform.lock.hcl` 추가
- `tofu init` 시 자동 재생성됨
- 재생성된 파일은 커밋하지 않음 (각 환경에서 독립 관리)

### 6. `provider.tf` - 변경 없음

기존 `api_token = var.cloudflare_api_token` 설정 그대로 유지.

## 마이그레이션 절차

1. **백업**: `cd domain/root && terraform state pull > terraform.tfstate.backup`
2. **파일 수정**: `backend.tf`, `version.tf`, `variables.tf`, `.github/workflows/terraform.yml`, `.gitignore`
3. **Lock 파일 삭제**: `rm domain/root/.terraform.lock.hcl`
4. **초기화**: `cd domain/root && tofu init -migrate-state` (Terraform Cloud → R2 state 마이그레이션)
5. **검증**: `cd domain/root && tofu plan`으로 변경 사항 없는지 확인
6. **적용**: `cd domain/root && tofu apply`
7. **CI/CD**: develop 브랜치 푸시 후 자동 실행 확인

> **롤백**: 마이그레이션 실패 시 `backend.tf`를 원래대로 복원 후 `terraform init -migrate-state`로 Terraform Cloud 복귀. 백업 파일(`terraform.tfstate.backup`)은 수동 복원용.

## 리스크 및 대응 방안

| 리스크 | 영향 | 대응 |
|------|------|------|
| State 손실 | 치명적 | 백업 파일로 복구. `terraform state pull` 사전 백업 필수 |
| R2 연결 실패 | 초기화 불가 | S3 backend config 및 R2 API credentials 확인 |
| CI/CD 실패 | 자동 배포 불가 | GitHub Secrets 확인, `working-directory: domain/root` 확인 |
| `.terraform.lock.hcl` 충돌 | init 실패 | 파일 삭제 후 `tofu init` 재실행 |
| Provider 호환성 | 다운로드 실패 | OpenTofu는 Terraform Registry 프로바이더 호환 |

## 사전 조건

- OpenTofu 1.8+ 설치됨 (`use_lockfile` 지원)
- R2 버킷 `terraform-state` 존재
- R2 API Token 생성 필요 (권한: 객체 읽기/쓰기/삭제)
- GitHub Secrets 설정 완료
