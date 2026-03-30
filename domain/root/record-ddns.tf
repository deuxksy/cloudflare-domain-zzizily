resource "cloudflare_dns_record" "ddns-netgear" {
  zone_id = var.cloudflare_zone_id
  name    = "ddns-netgear.${var.cloudflare_domain}"
  content = "49.161.254.152"
  type    = "A"
  ttl     = 3600
}
