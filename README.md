# zzizily.com

Cloudflare DNS 관리 - OpenTofu + R2 Backend

## 구조

```
├── .github/workflows/   # CI/CD (OpenTofu plan/apply)
├── domain/root/          # zzizily.com DNS 레코드
│   ├── backend.tf        # R2 state backend
│   ├── provider.tf       # Cloudflare provider
│   ├── record-*.tf       # DNS 레코드 정의
│   └── page-rule.tf      # Page Rule
├── .env.example          # 환경 변수 템플릿
└── docs/                 # 설계 문서
```

## 시작하기

```bash
# 1. .env 복사 후 값 입력
cp .env.example .env

# 2. OpenTofu 초기화
source .env && cd domain/root && tofu init

# 3. 변경 사항 확인
source .env && cd domain/root && tofu plan

# 4. 적용
source .env && cd domain/root && tofu apply
```

## 환경 변수

| 변수 | 설명 |
|------|------|
| `AWS_ACCESS_KEY_ID` | R2 접근용 Access Key |
| `AWS_SECRET_ACCESS_KEY` | R2 접근용 Secret Key |
| `TF_VAR_cloudflare_api_token` | Cloudflare API Token |
| `TF_VAR_cloudflare_zone_id` | Cloudflare Zone ID |
| `TF_VAR_cloudflare_domain` | 도메인 (zzizily.com) |
