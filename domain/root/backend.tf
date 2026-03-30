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
