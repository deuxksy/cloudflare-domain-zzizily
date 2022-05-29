terraform {
  backend "remote" {
    organization = "ZZiZiLY"
    workspaces {
      name = "zzizilycom-cloudflare"
    }
  }
}