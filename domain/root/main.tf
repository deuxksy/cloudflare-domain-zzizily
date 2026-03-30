terraform {
  required_version = ">= 1.8.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

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

    endpoints = {
      s3 = "https://e0924c382d21ac0f10aee606b82687ce.r2.cloudflarestorage.com"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_zone_id" {
  description = "Zone ID"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_domain" {
  description = "Domain"
  type        = string
  sensitive   = true
}
