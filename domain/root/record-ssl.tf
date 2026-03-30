resource "cloudflare_record" "_acme-challenge" {
  zone_id = var.cloudflare_zone_id
  name    = "_acme-challenge.${var.cloudflare_domain}"
  value   = "je1JUFVOn5J1S9hs2z1iY6zx6WakNMYcmerMPT08jSY"
  type    = "TXT"
  # allow_overwrite = true
}
