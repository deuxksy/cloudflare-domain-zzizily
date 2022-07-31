terraform {
  backend "remote" {
    organization = "ZZiZiLY"
    workspaces {
      name = "cloudflare-domain-zzizily"
    }
  }
}
