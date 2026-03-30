resource "cloudflare_dns_record" "local" {
  zone_id = var.cloudflare_zone_id
  name    = "local.${var.cloudflare_domain}"
  content = "127.0.0.1"
  type    = "A"
  ttl     = 3600
}
