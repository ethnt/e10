# gateway

resource "hcloud_server" "gateway" {
  name = "gateway"

  server_type = "cpx11"

  location = var.hcloud_primary_location

  image = "debian-12"

  ssh_keys = [hcloud_ssh_key.deploy.id]
  backups  = false

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.private_network.id
    ip         = "172.16.1.10"
  }

  lifecycle {
    ignore_changes = [ssh_keys, image]
  }

  depends_on = [hcloud_network_subnet.default_private_network_subnet]
}

module "gateway_install" {
  source = "github.com/numtide/nixos-anywhere//terraform/install"

  flake = "${abspath("${path.root}/../..")}#gateway"

  target_host = hcloud_server.gateway.ipv4_address
  target_user = "root"

  instance_id = hcloud_server.gateway.id

  ssh_private_key = tls_private_key.deploy_key.private_key_openssh

  phases = ["kexec", "disko", "install", "reboot"]

  build_on_remote = false
}

# monitor

resource "hcloud_server" "monitor" {
  name = "monitor"

  server_type = "cpx21"

  location = var.hcloud_secondary_location

  image = "debian-12"

  ssh_keys = [hcloud_ssh_key.deploy.id]
  backups  = false

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  lifecycle {
    ignore_changes = [ssh_keys, image]
  }
}

module "monitor_install" {
  source = "github.com/numtide/nixos-anywhere//terraform/install"

  flake = "${abspath("${path.root}/../..")}#monitor"

  target_host = hcloud_server.monitor.ipv4_address
  target_user = "root"

  instance_id = hcloud_server.monitor.id

  ssh_private_key = tls_private_key.deploy_key.private_key_openssh

  phases = ["kexec", "disko", "install", "reboot"]

  build_on_remote = false

  extra_files_script = abspath("${path.root}/servers/monitor-extra-files.sh")
}
