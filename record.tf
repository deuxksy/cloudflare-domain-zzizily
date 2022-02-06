resource "cloudflare_record" "local" {
  zone_id = var.zone_id
  name    = "local"
  value   = "127.0.0.1"
  type    = "A"
  proxied = true
}

# Add a record to the domain
resource "cloudflare_record" "foobar" {
  zone_id = var.cloudflare_zone_id
  name    = "terraform"
  value   = "192.168.0.11"
  type    = "A"
  ttl     = 3600
}