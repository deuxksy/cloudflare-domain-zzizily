
resource "cloudflare_record" "_domainconnect" {
  zone_id         = var.cloudflare_zone_id
  name            = "_domainconnect"
  value           = "connect.domains.google.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "blog" {
  zone_id         = var.cloudflare_zone_id
  name            = "blog"
  value           = "blog.zzizily.com.ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "calendar" {
  zone_id         = var.cloudflare_zone_id
  name            = "calendar"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "drive" {
  zone_id         = var.cloudflare_zone_id
  name            = "drive"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "mail" {
  zone_id         = var.cloudflare_zone_id
  name            = "mail"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "dkim" {
  zone_id         = var.cloudflare_zone_id
  name            = "google._domainkey"
  value           = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxk4BaiEwa+9I1eTAkYgVm1Cand7VAO1TSoAEXs3yIUIUAuILyBU+JtOabXdc8utD8hvNv99FuPae1jcV+ny1BxymggM1oMkseoKO2jKML87rwkCde9dRuMdNfsVvi874Ugvv3/HuM5uEmY+Mreli7fAYuowZX8Biy0vhkD1MdKwIDAQAB"
  type            = "TXT"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "sites" {
  zone_id         = var.cloudflare_zone_id
  name            = "sites"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "test" {
  zone_id         = var.cloudflare_zone_id
  name            = "test"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "www" {
  zone_id         = var.cloudflare_zone_id
  name            = "www"
  value           = "ghs.googlehosted.com"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

