resource "cloudflare_record" "tech" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "tech"
  value   = "deuxksy.github.io"
  proxied = true
}

resource "cloudflare_record" "tlog" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "tlog"
  value   = "blog.tistory.com"
  proxied = true
}
