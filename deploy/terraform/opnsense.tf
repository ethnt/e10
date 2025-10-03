locals {
  interfaces = {
    LAN        = "lan"
    Management = "opt1"
    IoT        = "opt5"
    Tailscale  = "opt3"
    Homelab    = "opt2"
  }

  vlans = {
    Management = {
      tag    = 2
      parent = "ixl1"
    }

    Homelab = {
      tag    = 10
      parent = "ixl1"
    }

    Guest = {
      tag    = 50
      parent = "ixl1"
    }

    IoT = {
      tag    = 100
      parent = "ixl1"
    }
  }
}

resource "opnsense_firewall_alias" "private_networks" {
  name        = "PrivateNetworks"
  type        = "network"
  content     = ["10.0.0.0/8", "192.168.1.0/16", "172.16.0.0/12", "192.168.0.0/16"]
  description = "[Terraform] All RFC 1918 private network addresses"
}

resource "opnsense_firewall_alias" "ps5_host" {
  name        = "PS5_Host"
  type        = "mac"
  content     = ["00:e4:21:15:bd:e8"]
  description = "[Terraform] PlayStation 5"
}

resource "opnsense_firewall_alias" "htpc_host" {
  name        = "HTPC_Host"
  type        = "host"
  content     = ["10.10.2.101"]
  description = "[Terraform] HTPC"
}

resource "opnsense_firewall_alias" "plex_port" {
  name        = "Plex_Port"
  type        = "port"
  content     = ["32400"]
  description = "[Terraform] HTPC"
}

resource "opnsense_firewall_alias" "matrix_host" {
  name        = "Matrix_Host"
  type        = "host"
  content     = ["10.10.3.101"]
  description = "[Terraform] Matrix"
}

resource "opnsense_firewall_alias" "denylist_geoip" {
  name        = "Denylist_GeoIP"
  type        = "geoip"
  content     = ["CN", "IR", "KP", "RU"]
  description = "[Terraform] Countries to deny access to"
}

resource "opnsense_firewall_filter" "interface_to_any" {
  for_each = local.interfaces

  enabled = true

  direction = "in"
  action    = "pass"
  interface = [each.value]
  source = {
    net = each.value
  }
  destination = {
    net = "any"
  }
  protocol    = "any"
  description = "[Terraform] ${each.key} to any rule"
  log         = true
}

resource "opnsense_firewall_filter" "interface_ipv6_to_any" {
  for_each = local.interfaces

  enabled = true

  direction = "in"
  action    = "pass"
  interface = [each.value]
  source = {
    net = each.value
  }
  destination = {
    net = "any"
  }
  protocol    = "any"
  ip_protocol = "inet6"
  description = "[Terraform] ${each.key} to any rule"
  log         = true
}

resource "opnsense_firewall_filter" "denylist_geoip_to_wan" {
  enabled   = true
  direction = "in"
  action    = "reject"
  interface = ["wan"]
  source = {
    net = "Denylist_GeoIP"
  }
  protocol    = "any"
  description = "[Terraform] Denylist GeoIP to WAN rule"
  log         = true
}

resource "opnsense_interfaces_vlan" "vlan" {
  for_each = local.vlans

  parent = each.value.parent
  tag    = each.value.tag

  description = each.key
}
