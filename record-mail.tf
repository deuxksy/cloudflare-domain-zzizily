resource "cloudflare_record" "mx" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  value    = "ASPMX.L.GOOGLE.COM"
  type     = "MX"
  ttl      = 3600
  priority = 1
}

resource "cloudflare_record" "mx5-1" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  value    = "ALT1.ASPMX.L.GOOGLE.COM"
  type     = "MX"
  ttl      = 3600
  priority = 5
}

resource "cloudflare_record" "mx5-2" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  value    = "ALT2.ASPMX.L.GOOGLE.COM"
  type     = "MX"
  ttl      = 3600
  priority = 5
}

resource "cloudflare_record" "mx10-1" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  value    = "ALT3.ASPMX.L.GOOGLE.COM"
  type     = "MX"
  ttl      = 3600
  priority = 10
}

resource "cloudflare_record" "mx10-2" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  value    = "ALT4.ASPMX.L.GOOGLE.COM"
  type     = "MX"
  ttl      = 3600
  priority = 10
}

