variable "cloudflare_email" {
  description = "E-Mail"
  type        = string
  sensitive   = true
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