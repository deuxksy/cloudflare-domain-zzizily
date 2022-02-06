terraform {
  backend "remote" {
    organization = "ZZiZiLY"
    token        = "FSN2md9UujIl0A.atlasv1.Ak2Q5T2c25hzlfUB42DYu3mvCYZYXABjRWfRxN81uPQrS4wP3riBUaHxy98FuMFtzzU"
    workspaces {
      name = "zzizilycom-cloudflare"
    }
  }
}