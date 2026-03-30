# OpenTofu Migration Design

 zzizily.com 도메인 Cloudflare Terraform → OpenTofu 마이그레이이

## 개요

 Terraform CLI를 OpenTofu CLI로 마이그레이션하고, 상태 백엔드를 Terraform Cloud(Remote)에서 Cloudflare R2(S3 호환)로 전환합니다 Provider 버전(`~> 3.20.0`)은 유지, CI/CD GitHub Actions 워크플로우 함께 업데이트.

## 변경 범위

| 파일 | 변경 내용 |
|------|----------|
| `backend.tf` | `remote` → `s3`(R2) |
| `version.tf` | `required_version` 추가, `required_providers` 유지 |
| `.github/workflows/terraform.yml` | `hashicorp/setup-terraform` → `opentofu/setup-opentofu` 교체 |
| GitHub Secrets | `TF_API_TOKEN` 삭제, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `R2_ENDPOINT_URL_S3` 추가 |

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
    endpoint                    = "https://<ACCOUNT_ID>.r2.cloudflarestorage.com"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_lockfile               = true
  }
}
```

> **참고**: `endpoint`의 `<ACCOUNT_ID>`는 Cloudflare 대시보드에서 확인 가능. `use_lockfile = true`은 OpenTofu 1.8+에서 지원하는 lockfile 기반 state locking.
 환경 변수로 `ACCOUNT_ID` 주입 또는 하드코딩 불가. 환경 변수를 우선.

 `endpoint`는 `AWS_ENDPOINT_URL_S3` 환경 변수를 통해 전달.

 `terraform init` 시 `AWS_ENDPOINT_URL`로 전달되도 S3 클라이언트와 통신에 사용합니다.

 자세한 내용은 OpenTofu 공식에서 S3 backend 구성을 가이드를 따름.

 계정 정보가 파일에 하드코딩되지 않도록 CI/CD에서 설정 가능.### 2. `version.tf` - 버전 정보 업데이트

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

> OpenTofu 1.8+ 필요 (lockfile 기반 state locking 지원). Provider는 변경 없음. 소스를 그대로 두고 Terraform Registry 사용 가능. `required_version`은 향후 호환성 보장. 런타임 오류 방지. 기본 클라 `>= 1.8.0`으로 설정.### 3. `.github/workflows/terraform.yml` - CI/CD 업데이트

**기존:**
- `hashicorp/setup-terraform@v1`
- `terraform fmt/init/validate/plan/apply` 명령어
- `TF_API_TOKEN` 시크릿 자격 증명 (Terraform Cloud)
)

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
        run: tofu fmt
        working-directory: domain/root

      - name: tofu init
        id: init
        run: tofu init
        working-directory: domain/root
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_ENDPOINT_URL_S3: ${{ secrets.R2_ENDPOINT_URL_S3 }}
          TF_VAR_cloudflare_api_token: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          TF_VAR_cloudflare_zone_id: ${{ secrets.CLOUDFLARE_ZONE_id }}
          TF_VAR_cloudflare_domain: ${{ secrets.CLOUDFLARE_DOMAIN }}

      - name: tofu validate
        id: validate
        run: tofu validate -no-color
        working-directory: domain/root
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_ENDPOINT_URL_S3: ${{ secrets.R2_ENDPOINT_URL_S3 }}
          TF_VAR_cloudflare_api_token: ${{ secrets.CLOUDFLARE_api_token }}
          TF_VAR_cloudflare_zone_id: ${{ secrets.CLOUDFLARE_zone_id }}
          TF_VAR_cloudflare_domain: ${{ secrets.cLOUDFLARE_domain }}

      - name: tofu plan
        id: plan
        if: github.event_name == 'pull_request'
        run: tofu plan -no-color
        working-directory: domain/root
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_ENDPOINT_URL_S3: ${{ secrets.R2_ENDPOINT_URL_S3 }}
          TF_VAR_cloudflare_api_token: ${{ secrets.CLOUDFLARE_api_token }}
          TF_VAR_cloudflare_zone_id: ${{ secrets.CLOUDFLARE_zone_id }}
          TF_VAR_cloudflare_domain: ${{ secrets.CLOUDFLARE_domain }}
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
          AWS_ENDPOINT_URL_S3: ${{ secrets.R2_ENDPOINT_URL_S3 }}
          TF_VAR_cloudflare_api_token: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          TF_VAR_cloudflare_zone_id: ${{ secrets.CLOUDFLARE_ZONE_ID }}
          TF_VAR_cloudflare_domain: ${{ secrets.CLOUDFLARE_DOMAIN }}
```

**GitHub Secrets 추가:**
- `AWS_ACCESS_KEY_ID`: R2 API Token (Access Key ID)
- `AWS_SECRET_ACCESS_KEY`: R2 API Token (Secret Access Key)
- `R2_ENDPOINT_URL_S3`: S3 엔드포인트 URL (예: `https://<ACCOUNT_ID>.r2.cloudflarestorage.com`)
- `CLOUDFLARE_API_TOKEN`: 기존 Cloudflare API Token
- `CLOUDFLARE_ZONE_ID`: 기존 Cloudflare Zone ID
- `CLOUDFLARE_DOMAIN`: 도메인 이름 (zzizily.com)

> **기존 Secret 삭제:** `TF_API_TOKEN` (Terraform Cloud용)

### 4. `variables.tf` - 환경 변수 정리

기존 `cloudflare_email` variable는 제거 (미사용). 나머지 변수는 유지.

### 5. `.terraform.lock.hcl` - Provider Lock 파일

기존 `.terraform.lock.hcl`이 `registry.terraform.io/hashicorp/cloudflare`를 참조. OpenTofu는 기본적으로 Terraform Registry를 통해 프로바이더를 다운로드하므로 `.terraform.lock.hcl`의 수정이 필요 없을 가능성이 높음. 단, lockfile 내용이 달라질 수 있으 Git에 커밋하는 것이 좋습니다.

> **권장**: `.terraform.lock.hcl` 파일 삭제 후 `.gitignore`에 추가. `tofu init` 시 자동 재생성됨.

### 6. `provider.tf` - 변경 없음

기존 `api_token = var.cloudflare_api_token` 설정 그대로 유지.

## 마이그레이션 절차

1. **백업**: `terraform state pull > terraform.tfstate.backup`
2. **파일 수정**: `backend.tf`, `version.tf`, `variables.tf`, `.github/workflows/terraform.yml`
3. **Provider lock 파일 삭제**: `rm domain/root/.terraform.lock.hcl`
4. **초기화**: `tofu init -migrate-state` (Terraform Cloud → R2 state 마이그레이션)
5. **검증**: `tofu plan`으로 변경 사항 없는지 확인
6. **적용**: `tofu apply`
7. **CI/CD**: develop 브랜치 푸시 후 자동 실행 확인

## 리스크 및 대응 방안

| 리스크 | 영향 | 대응 |
|------|------|------|
| State 손실 | 치명적 | `tofu init -migrate-state` 실패 시 백업 파일로 복구 |
| R2 연결 실패 | 초기화 불가 | S3 backend config 및 R2 API credentials 확인 |
| CI/CD 실패 | 자동 배포 불가 | GitHub Secrets 확인, `working-directory` 경로 확인 |
| `.terraform.lock.hcl` 충돌 | init 실패 | 파일 삭제 후 재시도 |
| Provider 호환성 | 다운로드 실패 | OpenTofu는 Terraform Registry 프로바이더 호환 (3.20.0 확인) |

## 사전 조건

- OpenTofu 1.8+ 설치됨 (`use_lockfile` 지원)
- R2 버킷 `terraform-state` 존재
- R2 API Token 생성 필요 (권한: 객체 읽기/쓰기/삭제 최소)
- GitHub Secrets 설정 (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, R2_ENDPOINT_URL_S3)
