resource "cloudflare_dns_record" "tech" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "tech.${var.cloudflare_domain}"
  content = "deuxksy.github.io"
  ttl     = 1
  proxied = true
}
