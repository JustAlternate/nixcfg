terraform {
	required_version = ">= 1.9.8"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 5.0"
    }
  }
}

variable "cloudflare_token" {
  description = "cloudflare API key"
  type        = string
	sensitive   = true
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

resource "cloudflare_zone" "justalternate_zone" {
	account = {
		id = "2e927365979a96c77a03b9545911f007"
	}
  name = "justalternate.com"
	type = "full"	
}

resource "cloudflare_dns_record" "JustAlternate-default" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "@"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "JustAlternate-planka" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "planka"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_zone" "ghexplorer_zone" {
	account = {
		id = "2e927365979a96c77a03b9545911f007"
	}
  name = "gh-explorer.com"
	type = "full"	
}

resource "cloudflare_dns_record" "GHExplorer-default" {
  zone_id  = cloudflare_zone.ghexplorer_zone.id
  name     = "@"
  type     = "A"
  content  = "188.245.183.30"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "GHExplorer-metrics" {
  zone_id  = cloudflare_zone.ghexplorer_zone.id
  name     = "metrics"
  type     = "A"
  content  = "188.245.183.30"
  ttl      = 120
  proxied  = false
}
