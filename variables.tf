variable "email" {
  description = "E-Mail"
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Zone ID"
  type        = string
  sensitive   = true
}

variable "api_token" {
  description = "API Token"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Domain"
  type        = string
  sensitive   = true
  default = "zzizily.com"
}