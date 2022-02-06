terraform {
  backend "remote" {
    organization = "ZZiZiLY"
    token        = var.tf_login_token
    workspaces {
      name = "zzizilycom-cloudflare"
    }
  }
}