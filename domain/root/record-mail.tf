resource "cloudflare_dns_record" "mx" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 1
}

resource "cloudflare_dns_record" "mx5-1" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "alt1.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 5
}

resource "cloudflare_dns_record" "mx5-2" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "alt2.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 5
}

resource "cloudflare_dns_record" "mx10-1" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "alt3.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 10
}

resource "cloudflare_dns_record" "mx10-2" {
  zone_id  = var.cloudflare_zone_id
  name     = var.cloudflare_domain
  content  = "alt4.aspmx.l.google.com"
  type     = "MX"
  ttl      = 3600
  priority = 10
}
