# OpenTofu Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Terraform CLI + Terraform Cloud 백엔드를 OpenTofu CLI + Cloudflare R2(S3) 백엔드로 마이그레이션

**Architecture:** Terraform Cloud remote backend를 S3 호환 Cloudflare R2로 교체. `tofu init -migrate-state`로 state를 자동 마이그레이션. GitHub Actions 워크플로우를 opentofu 기반으로 재작성.

**Tech Stack:** OpenTofu 1.9.0, Cloudflare R2 (S3 호환), GitHub Actions, Cloudflare Provider ~> 3.20.0

---

## File Structure

| 파일 | 작업 | 설명 |
|------|------|------|
| `domain/root/backend.tf` | 수정 | `remote` → `s3`(R2) |
| `domain/root/version.tf` | 수정 | `required_version` 추가 |
| `domain/root/variables.tf` | 수정 | `cloudflare_email` 제거 |
| `domain/root/.terraform.lock.hcl` | 삭제 | OpenTofu 재생성 |
| `.github/workflows/terraform.yml` | 재작성 | OpenTofu 기반 CI/CD |
| `.gitignore` | 수정 | `.terraform.lock.hcl` 추가 |

---

### Task 0: 기존 State 백업 (파일 수정 전 선행)

**Files:** 없음 (로컬 상태 백업)

> **중요**: `backend.tf` 변경 전에 Terraform Cloud에서 state를 백업해야 함. 변경 후에는 Terraform Cloud에 접근 불가.

- [ ] **Step 1: 기존 backend로 terraform init**

```bash
cd domain/root
terraform init
```

Expected: Terraform Cloud backend로 초기화 성공

- [ ] **Step 2: State 백업**

```bash
terraform state pull > terraform.tfstate.backup
```

Expected: `terraform.tfstate.backup` 파일 생성됨. 파일 크기 > 0 확인.

- [ ] **Step 3: 백업 파일 검증**

```bash
python3 -c "import json; d=json.load(open('terraform.tfstate.backup')); print(f'Resources: {len(d.get(\"resources\", []))}')"
```

Expected: 리소스 개수 출력됨 (0 이상)

---

### Task 1: `backend.tf` S3(R2) 백엔드로 교체

**Files:**
- Modify: `domain/root/backend.tf`

- [ ] **Step 1: `backend.tf` 전체 교체**

기존 Terraform Cloud remote 설정을 S3(R2)로 교체:

```hcl
terraform {
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "cloudflare/dns/terraform.tfstate"
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

- [ ] **Step 2: 파일 내용 확인**

Run: `cat domain/root/backend.tf`
Expected: 위 HCL 내용과 일치

- [ ] **Step 3: Commit**

```bash
git add domain/root/backend.tf
git commit -m "refactor: backend.tf Terraform Cloud → R2 S3 백엔드로 교체"
```

---

### Task 2: `version.tf` 업데이트

**Files:**
- Modify: `domain/root/version.tf`

- [ ] **Step 1: `required_version` 추가**

기존 `required_providers` 블록 위에 `required_version` 추가:

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

- [ ] **Step 2: 파일 내용 확인**

Run: `cat domain/root/version.tf`
Expected: `required_version = ">= 1.8.0"` 포함

- [ ] **Step 3: Commit**

```bash
git add domain/root/version.tf
git commit -m "feat: version.tf required_version 추가 (OpenTofu 1.8+)"
```

---

### Task 3: `variables.tf` 미사용 변수 제거

**Files:**
- Modify: `domain/root/variables.tf`

- [ ] **Step 1: `cloudflare_email` 변수 블록 삭제**

`variables.tf`에서 아래 블록 제거:

```hcl
variable "cloudflare_email" {
  description = "E-Mail"
  type        = string
  sensitive   = true
}
```

나머지 변수(`cloudflare_zone_id`, `cloudflare_api_token`, `cloudflare_domain`)는 유지.

- [ ] **Step 2: 파일 내용 확인**

Run: `cat domain/root/variables.tf`
Expected: `cloudflare_email` 변수 없음, 나머지 3개 변수 존재

- [ ] **Step 3: Commit**

```bash
git add domain/root/variables.tf
git commit -m "refactor: variables.tf 미사용 cloudflare_email 변수 제거"
```

---

### Task 4: `.terraform.lock.hcl` 삭제 및 `.gitignore` 업데이트

**Files:**
- Delete: `domain/root/.terraform.lock.hcl`
- Modify: `.gitignore`

- [ ] **Step 1: 기존 lock 파일 삭제**

Run: `rm domain/root/.terraform.lock.hcl`

- [ ] **Step 2: `.gitignore`에 `.terraform.lock.hcl` 추가**

`.gitignore` 파일 끝에 추가:

```
# OpenTofu lock file (auto-generated)
.terraform.lock.hcl
```

- [ ] **Step 3: `.gitignore` 내용 확인**

Run: `cat .gitignore`
Expected: `.terraform.lock.hcl` 포함

- [ ] **Step 4: Commit**

```bash
git add .gitignore
git rm --cached domain/root/.terraform.lock.hcl
git commit -m "chore: .terraform.lock.hcl 삭제 및 .gitignore 추가"
```

---

### Task 5: GitHub Actions 워크플로우 재작성

**Files:**
- Rewrite: `.github/workflows/terraform.yml`

- [ ] **Step 1: 워크플로우 파일 전체 재작성**

기존 파일을 아래 내용으로 교체:

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

- [ ] **Step 2: YAML 문법 검증**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/terraform.yml'))"`
Expected: 에러 없이 완료

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/terraform.yml
git commit -m "ci: GitHub Actions Terraform → OpenTofu 워크플로우 재작성"
```

---

### Task 6: 로컬 환경 변수 설정 및 State 마이그레이션

**Files:** 없음 (로컬 환경 설정)

- [ ] **Step 1: 환경 변수 설정**

R2 credentials와 Cloudflare credentials를 환경 변수로 설정:

```bash
export AWS_ACCESS_KEY_ID=<YOUR_R2_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<YOUR_R2_SECRET_ACCESS_KEY>
export TF_VAR_cloudflare_api_token=<기존_값>
export TF_VAR_cloudflare_zone_id=<기존_값>
export TF_VAR_cloudflare_domain=zzizily.com
```

> **주의**: 실제 TF_VAR_ 값은 Terraform Cloud 또는 기존 로컬 설정에서 확인. State 백업은 Task 0에서 이미 완료됨.

- [ ] **Step 2: `tofu init -migrate-state` 실행**

```bash
tofu init -migrate-state
```

Expected:
- Terraform Cloud에서 state를 pull
- R2에 state를 push
- "Successfully migrated state" 메시지 출력

- [ ] **Step 3: `tofu validate` 실행**

```bash
tofu validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 4: `tofu plan` 실행 (변경 사항 없어야 함)**

```bash
tofu plan
```

Expected: `No changes. Infrastructure is up-to-date.` 또는 동등한 메시지

- [ ] **Step 5: 백업 파일 정리**

마이그레이션 성공 확인 후:
```bash
rm terraform.tfstate.backup
```

---

### Task 7: 최종 검증 및 정리

**Files:** 없음

- [ ] **Step 1: R2 버킷에 state 파일 존재 확인**

Cloudflare Dashboard → R2 → `terraform-state` 버킷에서 `cloudflare/dns/terraform.tfstate` 파일 존재 확인.

- [ ] **Step 2: 전체 git status 확인**

Run: `git status`
Expected: 작업 디렉토리 clean (모든 변경 커밋됨)

- [ ] **Step 3: GitHub Secrets 설정 확인**

GitHub Repository → Settings → Secrets and variables → Actions에서 아래 시크릿 존재 확인:
- `AWS_ACCESS_KEY_ID` (R2 Access Key)
- `AWS_SECRET_ACCESS_KEY` (R2 Secret Key)
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ZONE_ID`
- `CLOUDFLARE_DOMAIN`

> **기존 `TF_API_TOKEN` 삭제**: Terraform Cloud용 시크릿 제거

- [ ] **Step 4: develop 브랜치에 push하여 CI/CD 검증**

```bash
git push origin develop
```

Expected: GitHub Actions 워크플로우가 OpenTofu로 실행됨. `tofu apply` 성공.
