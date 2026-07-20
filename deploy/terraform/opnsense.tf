locals {
  trusted_interfaces = {
    LAN        = "lan"
    Management = "opt1"
    Tailscale  = "opt3"
    Homelab    = "opt2"
  }

  untrusted_interfaces = {
    IoT = "opt5"
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
  content     = ["10.2.0.0/16", "10.10.0.0/16", "10.50.0.0/16", "192.168.1.0/16", "172.16.0.0/12", "192.168.0.0/16"]
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

resource "opnsense_firewall_filter" "trusted_interface_to_any" {
  for_each = local.trusted_interfaces

  enabled = true

  interface = {
    interface = [each.value]
  }

  filter = {
    quick     = true
    direction = "in"
    action    = "pass"
    protocol  = "any"

    source = {
      net = each.value
    }

    destination = {
      net = "any"
    }

    log = true
  }

  description = "[Terraform] ${each.key} to any rule"
}

resource "opnsense_firewall_filter" "trusted_interface_ipv6_to_any" {
  for_each = local.trusted_interfaces

  enabled = true

  interface = {
    interface = [each.value]
  }

  filter = {
    quick       = true
    direction   = "in"
    action      = "pass"
    protocol    = "any"
    ip_protocol = "inet6"

    source = {
      net = each.value
    }

    destination = {
      net = "any"
    }

    log = true
  }

  description = "[Terraform] ${each.key} to any rule"
}

resource "opnsense_firewall_filter" "denylist_geoip_to_wan" {
  enabled = true

  interface = {
    interface = ["wan"]
  }

  filter = {
    quick     = true
    direction = "in"
    action    = "reject"
    protocol  = "any"

    source = {
      net = "Denylist_GeoIP"
    }

    log = true
  }

  description = "[Terraform] Denylist GeoIP to WAN rule"
}

resource "opnsense_firewall_filter" "untrusted_interface_to_dns" {
  for_each = local.untrusted_interfaces

  enabled  = true
  sequence = 1

  interface = {
    interface = [each.value]
  }

  filter = {
    quick     = true
    direction = "in"
    action    = "pass"
    protocol  = "TCP/UDP"

    source = {
      net = each.value
    }

    destination = {
      net  = "${each.value}ip"
      port = "53"
    }

    log = true
  }

  description = "[Terraform] ${each.key} to DNS rule"
}

resource "opnsense_firewall_filter" "untrusted_interface_to_private_networks" {
  for_each = local.untrusted_interfaces

  enabled  = true
  sequence = 2

  interface = {
    interface = [each.value]
  }

  filter = {
    quick     = true
    direction = "in"
    action    = "block"
    protocol  = "any"

    source = {
      net = each.value
    }

    destination = {
      net = "PrivateNetworks"
    }

    log = true
  }

  description = "[Terraform] ${each.key} to private networks block rule"
}

resource "opnsense_firewall_filter" "untrusted_interface_to_any" {
  for_each = local.untrusted_interfaces

  enabled  = true
  sequence = 3

  interface = {
    interface = [each.value]
  }

  filter = {
    quick     = true
    direction = "in"
    action    = "pass"
    protocol  = "any"

    source = {
      net = each.value
    }

    destination = {
      net = "any"
    }

    log = true
  }

  description = "[Terraform] ${each.key} to any (internet) rule"
}

resource "opnsense_interfaces_vlan" "vlan" {
  for_each = local.vlans

  parent = each.value.parent
  tag    = each.value.tag

  description = each.key
}
