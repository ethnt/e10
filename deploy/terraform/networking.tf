resource "hcloud_network" "private_network" {
  name     = "private-network"
  ip_range = "172.16.0.0/16"
}

resource "hcloud_network_subnet" "default_private_network_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.private_network.id
  network_zone = "us-east"
  ip_range     = "172.16.1.0/24"
}
