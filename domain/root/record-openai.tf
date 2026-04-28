resource "cloudflare_dns_record" "openai-domain-verification" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_domain
  content = "openai-domain-verification=dv-8wdTkH7ZEXNIeccgcBGlzntV"
  type    = "TXT"
  ttl     = 3600
}
