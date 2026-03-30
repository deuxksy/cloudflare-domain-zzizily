resource "cloudflare_dns_record" "_domainconnect" {
  zone_id = var.cloudflare_zone_id
  name    = "_domainconnect.${var.cloudflare_domain}"
  content = "connect.domains.google.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "blog" {
  zone_id = var.cloudflare_zone_id
  name    = "blog.${var.cloudflare_domain}"
  content = "deuxksy.github.io"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "calendar" {
  zone_id = var.cloudflare_zone_id
  name    = "calendar.${var.cloudflare_domain}"
  content = "ghs.googlehosted.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "drive" {
  zone_id = var.cloudflare_zone_id
  name    = "drive.${var.cloudflare_domain}"
  content = "ghs.googlehosted.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "mail" {
  zone_id = var.cloudflare_zone_id
  name    = "mail.${var.cloudflare_domain}"
  content = "ghs.googlehosted.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "dkim" {
  zone_id = var.cloudflare_zone_id
  name    = "google._domainkey.${var.cloudflare_domain}"
  content = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxk4BaiEwa+9I1eTAkYgVm1Cand7VAO1TSoAEXs3yIUIUAuILyBU+JtOabXdc8utD8hvNv99FuPae1jcV+ny1BxymggM1oMkseoKO2jKML87rwkCde9dRuMdNfsVvi874Ugvv3/HuM5uEmY+Mreli7fAYuowZX8Biy0vhkD1MdKwIDAQAB"
  type    = "TXT"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_dns_record" "sites" {
  zone_id = var.cloudflare_zone_id
  name    = "sites.${var.cloudflare_domain}"
  content = "ghs.googlehosted.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "test" {
  zone_id = var.cloudflare_zone_id
  name    = "test.${var.cloudflare_domain}"
  content = "ghs.googlehosted.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www.${var.cloudflare_domain}"
  content = "deuxksy.github.io"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
