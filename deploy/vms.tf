resource "proxmox_vm_qemu" "omnibus" {
  provider = proxmox.anise

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

  scsihw = "virtio-scsi-single"

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
    type     = "scsi"
    size     = "1024G"
    storage  = "local-zfs"
    discard  = "on"
    file     = "vm-101-disk-0"
    format   = "raw"
    slot     = 0
    volume   = "local-zfs:vm-101-disk-0"
    aio      = "threads"
    iothread = 1
  }
}

resource "proxmox_vm_qemu" "htpc" {
  provider = proxmox.basil

  name        = "htpc"
  target_node = "basil"
  iso         = "local:iso/latest-nixos-minimal-x86_64-linux.iso"
  vmid        = 101
  cpu         = "host,flags=+pcid"
  memory      = 32768
  balloon     = 0
  sockets     = 1
  cores       = 16
  qemu_os     = "other"
  scsihw      = "virtio-scsi-single"
  boot        = "order=scsi0"

  onboot = true
  agent  = 1

  bios = "seabios"

  network {
    model     = "virtio"
    bridge    = "vmbr0"
    tag       = 10
    macaddr   = "CE:22:2C:7F:DE:79"
    link_down = false
    firewall  = false
    mtu       = 0
    queues    = 0
    rate      = 0
  }

  disk {
    type    = "scsi"
    size    = "2048G"
    storage = "local-zfs"
    discard = "on"
    file    = "vm-101-disk-0"
    format  = "raw"
    slot    = 0
    volume  = "local-zfs:vm-101-disk-0"
  }
}

resource "proxmox_vm_qemu" "builder" {
  provider = proxmox.basil

  name        = "builder"
  target_node = "basil"
  iso         = "local:iso/latest-nixos-minimal-x86_64-linux.iso"
  vmid        = 102
  memory      = 16384
  balloon     = 0
  sockets     = 1
  cores       = 8
  qemu_os     = "other"
  scsihw      = "virtio-scsi-single"
  boot        = "order=scsi0"

  onboot = true
  agent  = 1

  bios = "seabios"

  network {
    model     = "virtio"
    bridge    = "vmbr0"
    tag       = 10
    macaddr   = "3A:7D:CB:E6:11:D9"
    link_down = false
    firewall  = false
    mtu       = 0
    queues    = 0
    rate      = 0
  }

  disk {
    type    = "scsi"
    size    = "2048G"
    storage = "local-zfs"
    discard = "on"
    file    = "vm-102-disk-0"
    format  = "raw"
    slot    = 0
    volume  = "local-zfs:vm-102-disk-0"
  }
}

resource "proxmox_vm_qemu" "matrix" {
  provider = proxmox.cardamom

  name        = "matrix"
  target_node = "cardamom"
  iso         = "omnibus:iso/latest-nixos-minimal-x86_64-linux.iso"
  vmid        = 101
  cpu         = "host"
  memory      = 32768
  balloon     = 0
  sockets     = 1
  cores       = 8
  qemu_os     = "other"
  scsihw      = "virtio-scsi-single"
  boot        = "order=scsi0"

  onboot = true
  agent  = 1

  bios = "seabios"

  network {
    model     = "virtio"
    bridge    = "vmbr0"
    macaddr   = "06:8D:3E:8F:5F:23"
    firewall  = false
    link_down = false
    mtu       = 0
    queues    = 0
    rate      = 0
    tag       = 10
  }

  disk {
    type    = "scsi"
    size    = "128G"
    storage = "local-zfs"
    discard = "on"
    file    = "vm-101-disk-0"
    format  = "raw"
    slot    = 0
    volume  = "local-zfs:vm-101-disk-0"
  }
}
