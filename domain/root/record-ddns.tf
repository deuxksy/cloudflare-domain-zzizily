resource "cloudflare_record" "ddns-netgear" {
  zone_id = var.cloudflare_zone_id
  name    = "ddns-netgear.${var.cloudflare_domain}"
  value   = "49.161.254.152"
  type    = "A"
}

resource "cloudflare_record" "ddns-linksys" {
  zone_id = var.cloudflare_zone_id
  name    = "ddns-linksys.${var.cloudflare_domain}"
  value   = "49.161.254.139"
  type    = "A"
}
