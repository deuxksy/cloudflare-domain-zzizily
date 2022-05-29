resource "cloudflare_record" "mx" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  value    = "aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 1
  allow_overwrite = true
}

resource "cloudflare_record" "mx5-1" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  value    = "alt1.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 5
  allow_overwrite = true
}

resource "cloudflare_record" "mx5-2" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  value    = "alt2.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 5
  allow_overwrite = true
}

resource "cloudflare_record" "mx10-1" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  value    = "alt3.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 10
  allow_overwrite = true
}

resource "cloudflare_record" "mx10-2" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  value    = "alt4.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 10
  allow_overwrite = true
}
