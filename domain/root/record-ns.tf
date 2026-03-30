resource "cloudflare_dns_record" "ns-netgear1" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("netgear.%s", var.cloudflare_domain)
  content = "ns-397.awsdns-49.com"
  ttl     = 3600
}

resource "cloudflare_dns_record" "ns-netgear2" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("netgear.%s", var.cloudflare_domain)
  content = "ns-787.awsdns-34.net"
  ttl     = 3600
}

resource "cloudflare_dns_record" "ns-netgear3" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("netgear.%s", var.cloudflare_domain)
  content = "ns-1305.awsdns-35.org"
  ttl     = 3600
}

resource "cloudflare_dns_record" "ns-netgear4" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("netgear.%s", var.cloudflare_domain)
  content = "ns-1936.awsdns-50.co.uk"
  ttl     = 3600
}
