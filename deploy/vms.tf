resource "proxmox_vm_qemu" "omnibus" {
  name        = "omnibus"
  target_node = "anise"
  iso         = "local:iso/latest-nixos-minimal-x86_64-linux.iso"
  vmid        = 101
  memory      = 57344
  balloon     = 0
  sockets     = 1
  cores       = 4
  qemu_os     = "other"

  onboot = true
  agent  = 1

  bios = "seabios"

  boot = "order=scsi0"

  network {
    model     = "virtio"
    bridge    = "vmbr0"
    tag       = 10
    macaddr   = "2E:E0:17:56:C3:51"
    link_down = false
    firewall  = false
    mtu       = 0
    queues    = 0
    rate      = 0
  }

  disk {
    type    = "scsi"
    size    = "1024G"
    storage = "local-zfs"
    discard = "on"
    file    = "vm-101-disk-0"
    format  = "raw"
    slot    = 0
    volume  = "local-zfs:vm-101-disk-0"
  }
}
