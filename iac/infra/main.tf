terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_token
}


resource "hcloud_network" "private_network" {
  name     = "private-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "default_private_network_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.private_network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_ssh_key" "my_ssh_key" {
  name       = "my-ssh-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "hcloud_server" "GHExplorer" {
  name        = "GHExplorer"
  server_type = "cax11"
  image       = "debian-12"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.my_ssh_key.id]
  network {
    network_id = hcloud_network.private_network.id
    # this will be the ip of the server in the private network
    # the public ip won't be known until the server is provisioned
    ip         = "10.0.1.3"
  }
}

module "NixOS_install_preprod_server" {
  source      = "./NixOS-install"
  target_host = hcloud_server.GHExplorer.ipv4_address
}
