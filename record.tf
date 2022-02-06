resource "cloudflare_record" "local" {
  zone_id = var.cloudflare_zone_id
  name    = "local"
  value   = "127.0.0.1"
  type    = "A"
  # allow_overwrite = true
}

resource "cloudflare_record" "root" {
  zone_id = var.cloudflare_zone_id
  name    = ""
  value   = "49.161.254.154"
  type    = "A"
  proxied = true
  # allow_overwrite = true
}
