resource "cloudflare_record" "local" {
  zone_id = var.cloudflare_zone_id
  name    = "local.${var.cloudflare_domain}"
  value   = "127.0.0.1"
  type    = "A"
  # allow_overwrite = true
}

resource "cloudflare_record" "nlog" {
  zone_id = var.cloudflare_zone_id
  type    = "A"
  name    = "nlog.${var.cloudflare_domain}"
  value   = "125.209.214.79"
  proxied = true
}
