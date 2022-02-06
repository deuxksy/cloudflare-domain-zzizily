resource "cloudflare_record" "local" {
  zone_id = var.zone_id
  name    = "local"
  value   = "127.0.0.1"
  type    = "A"
  proxied = true
}