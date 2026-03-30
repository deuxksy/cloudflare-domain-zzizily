resource "cloudflare_page_rule" "page_urle_1" {
  zone_id  = var.cloudflare_zone_id
  target   = format("%s/", var.cloudflare_domain)
  status   = "active"
  priority = 1

  actions {
    forwarding_url {
      url         = "https://github.com/deuxksy"
      status_code = 301
    }
  }
}