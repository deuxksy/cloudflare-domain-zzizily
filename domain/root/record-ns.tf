resource "cloudflare_record" "ns-forti1" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("forti.%s", var.cloudflare_domain)
  value   = "ns-1869.awsdns-41.co.uk"
}

resource "cloudflare_record" "ns-forti2" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("forti.%s", var.cloudflare_domain)
  value   = "ns-1460.awsdns-54.org"
}

resource "cloudflare_record" "ns-forti3" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("forti.%s", var.cloudflare_domain)
  value   = "ns-852.awsdns-42.net"
}

resource "cloudflare_record" "ns-forti4" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("forti.%s", var.cloudflare_domain)
  value   = "ns-110.awsdns-13.com"
}

resource "cloudflare_record" "ns-linksys1" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("linksys.%s", var.cloudflare_domain)
  value   = "ns-1831.awsdns-36.co.uk"
}

resource "cloudflare_record" "ns-linksys2" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("linksys.%s", var.cloudflare_domain)
  value   = "ns-1147.awsdns-15.org"
}

resource "cloudflare_record" "ns-linksys3" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("linksys.%s", var.cloudflare_domain)
  value   = "ns-35.awsdns-04.com"
}

resource "cloudflare_record" "ns-linksys4" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("linksys.%s", var.cloudflare_domain)
  value   = "ns-694.awsdns-22.net"
}

resource "cloudflare_record" "ns-netgear1" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("netgear.%s", var.cloudflare_domain)
  value   = "ns-397.awsdns-49.com"
}

resource "cloudflare_record" "ns-netgear2" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("netgear.%s", var.cloudflare_domain)
  value   = "ns-787.awsdns-34.net"
}

resource "cloudflare_record" "ns-netgear3" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("netgear.%s", var.cloudflare_domain)
  value   = "ns-1305.awsdns-35.org"
}

resource "cloudflare_record" "ns-netgear4" {
  zone_id = var.cloudflare_zone_id
  type    = "NS"
  name    = format("netgear.%s", var.cloudflare_domain)
  value   = "ns-1936.awsdns-50.co.uk"
}
