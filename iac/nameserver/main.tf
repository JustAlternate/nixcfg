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

resource "cloudflare_dns_record" "JustAlternate-pareto" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "pareto"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "JustAlternate-cloud" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "cloud"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "JustAlternate-vpn" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "vpn"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "JustAlternate-explorer" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "explorer"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "JustAlternate-ai" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "ai"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "JustAlternate-geo" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "geo"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "JustAlternate-monitoring" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "monitoring"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "JustAlternate-monitor" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "monitor"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "JustAlternate-play" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "play"
  type     = "A"
  content  = "195.201.116.51"
  ttl      = 120
  proxied  = false
}

resource "cloudflare_dns_record" "JustAlternate-vaultwarden" {
  zone_id  = cloudflare_zone.justalternate_zone.id
  name     = "vaultwarden"
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
