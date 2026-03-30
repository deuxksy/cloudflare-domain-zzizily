
resource "cloudflare_record" "_domainconnect" {
  zone_id         = var.cloudflare_zone_id
  name            = "_domainconnect.${var.cloudflare_domain}"
  value           = "connect.domains.google.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "blog" {
  zone_id         = var.cloudflare_zone_id
  name            = "blog.${var.cloudflare_domain}"
  value           = "deuxksy.github.io"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "calendar" {
  zone_id         = var.cloudflare_zone_id
  name            = "calendar.${var.cloudflare_domain}"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "drive" {
  zone_id         = var.cloudflare_zone_id
  name            = "drive.${var.cloudflare_domain}"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "mail" {
  zone_id         = var.cloudflare_zone_id
  name            = "mail.${var.cloudflare_domain}"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "dkim" {
  zone_id         = var.cloudflare_zone_id
  name            = "google._domainkey.${var.cloudflare_domain}"
  value           = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxk4BaiEwa+9I1eTAkYgVm1Cand7VAO1TSoAEXs3yIUIUAuILyBU+JtOabXdc8utD8hvNv99FuPae1jcV+ny1BxymggM1oMkseoKO2jKML87rwkCde9dRuMdNfsVvi874Ugvv3/HuM5uEmY+Mreli7fAYuowZX8Biy0vhkD1MdKwIDAQAB"
  type            = "TXT"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "sites" {
  zone_id         = var.cloudflare_zone_id
  name            = "sites.${var.cloudflare_domain}"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "test" {
  zone_id         = var.cloudflare_zone_id
  name            = "test.${var.cloudflare_domain}"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "www" {
  zone_id         = var.cloudflare_zone_id
  name            = "www.${var.cloudflare_domain}"
  value           = "deuxksy.github.io"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}
