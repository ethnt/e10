resource "proxmox_virtual_environment_vm" "omnibus" {
  provider = proxmox.anise

  node_name = "anise"

  name  = "omnibus"
  vm_id = 101

  scsi_hardware = "virtio-scsi-single"

  boot_order = ["scsi0"]
  migrate    = true

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 53248
  }

  disk {
    datastore_id = "local-zfs"
    discard      = "on"
    file_format  = "raw"
    interface    = "scsi0"
    size         = 1024
    iothread     = true
  }

  network_device {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
    queues   = 4
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  operating_system {
    type = "other"
  }

  vga {
    memory = 16
    type   = "std"
  }

  hostpci {
    device = "hostpci0"
    id     = "0000:07:00"
    pcie   = false
    rombar = false
    xvga   = false
  }

  hostpci {
    device = "hostpci1"
    id     = "0000:03:00"
    pcie   = false
    rombar = true
    xvga   = false
  }

  hostpci {
    device = "hostpci2"
    id     = "0000:04:00"
    pcie   = false
    rombar = true
    xvga   = false
  }

  hostpci {
    device = "hostpci3"
    id     = "0000:05:00"
    pcie   = false
    rombar = true
    xvga   = false
  }

  hostpci {
    device = "hostpci4"
    id     = "0000:06:00"
    pcie   = false
    rombar = true
    xvga   = false
  }
}

resource "proxmox_virtual_environment_vm" "htpc" {
  provider = proxmox.basil

  node_name = "basil"

  name  = "htpc"
  vm_id = 101

  scsi_hardware = "virtio-scsi-single"

  machine = "q35"

  boot_order = ["scsi0"]
  migrate    = true

  cpu {
    cores   = 16
    sockets = 1
    type    = "host"
    flags   = ["+pcid", "+spec-ctrl", "+ssbd"]
  }

  memory {
    dedicated = 49152
  }

  disk {
    datastore_id = "local-zfs"
    discard      = "on"
    file_format  = "raw"
    interface    = "scsi0"
    size         = 2048
    ssd          = false
    cache        = "writeback"
  }

  network_device {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  operating_system {
    type = "other"
  }

  vga {
    memory = 16
    type   = "std"
  }

  # Quadro P4000
  hostpci {
    device = "hostpci0"
    id     = "0000:02:00"
    pcie   = true
    rombar = true
    xvga   = false
  }

  # GeForce RTX 4060 Ti
  hostpci {
    device = "hostpci1"
    id     = "0000:01:00"
    pcie   = true
    rombar = true
    xvga   = false
  }
}

resource "proxmox_virtual_environment_vm" "builder" {
  provider = proxmox.basil

  node_name = "basil"

  name  = "builder"
  vm_id = 102

  scsi_hardware = "virtio-scsi-single"

  machine = "q35"

  boot_order = ["scsi0"]
  migrate    = true

  cpu {
    cores   = 8
    sockets = 1
    type    = "host"
    flags   = ["+pcid", "+spec-ctrl", "+ssbd"]
  }

  memory {
    dedicated = 32768
  }

  disk {
    datastore_id = "local-zfs"
    discard      = "on"
    file_format  = "raw"
    interface    = "scsi0"
    size         = 2048
  }

  network_device {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  operating_system {
    type = "other"
  }

  vga {
    memory = 16
    type   = "std"
  }
}

resource "proxmox_virtual_environment_vm" "matrix" {
  provider = proxmox.cardamom

  node_name = "cardamom"

  name  = "matrix"
  vm_id = 101

  scsi_hardware = "virtio-scsi-single"

  boot_order = ["scsi0"]
  migrate    = true

  cpu {
    cores   = 8
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 32768
  }

  disk {
    datastore_id = "local-zfs"
    discard      = "on"
    file_format  = "raw"
    interface    = "scsi0"
    size         = 128
  }

  network_device {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  operating_system {
    type = "other"
  }

  usb {
    host = "04f9:0061"
    usb3 = true
  }

  usb {
    host = "09ae:2012"
    usb3 = true
  }

  vga {
    memory = 16
    type   = "std"
  }

  hostpci {
    device = "hostpci0"
    id     = "0000:00:02"
    pcie   = false
    rombar = true
    xvga   = false
  }
}

resource "proxmox_virtual_environment_vm" "router" {
  provider = proxmox.elderflower

  node_name = "elderflower"

  name  = "router"
  vm_id = 101

  machine = "q35"
  bios    = "ovmf"

  scsi_hardware = "virtio-scsi-single"
  on_boot       = true

  migrate = true

  startup {
    down_delay = -1
    order      = 1
    up_delay   = -1
  }

  cpu {
    cores   = 8
    sockets = 1
    type    = "x86-64-v2-AES"
    flags   = ["+aes"]
  }

  memory {
    dedicated = 32768
  }

  disk {
    datastore_id = "local-zfs"
    discard      = "on"
    file_format  = "raw"
    interface    = "scsi0"
    size         = 256
    iothread     = true
    ssd          = true
  }

  efi_disk {
    datastore_id      = "local-zfs"
    file_format       = "raw"
    pre_enrolled_keys = false
    type              = "4m"
  }

  network_device {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  agent {
    enabled = true
  }

  vga {
    memory = 16
    type   = "std"
  }

  operating_system {
    type = "l26"
  }

  hostpci {
    device = "hostpci0"
    id     = "0000:02:00"
    pcie   = false
    rombar = true
    xvga   = false
  }

  hostpci {
    device = "hostpci1"
    id     = "0000:06:00"
    pcie   = false
    rombar = true
    xvga   = false
  }

  hostpci {
    device = "hostpci2"
    id     = "0000:00:1f.3"
    pcie   = false
    rombar = true
    xvga   = false
  }

  hostpci {
    device = "hostpci3"
    id     = "0000:05:00"
    pcie   = false
    rombar = true
    xvga   = false
  }
}

resource "proxmox_virtual_environment_vm" "controller" {
  provider = proxmox.elderflower

  node_name = "elderflower"

  name  = "controller"
  vm_id = 102

  scsi_hardware = "virtio-scsi-single"

  boot_order = ["scsi0"]
  migrate    = true

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-zfs"
    discard      = "on"
    file_format  = "raw"
    interface    = "scsi0"
    size         = 256
  }

  network_device {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  operating_system {
    type = "other"
  }

  vga {
    memory = 16
    type   = "std"
  }

  usb {
    host = "0463:ffff"
    usb3 = true
  }

  startup {
    down_delay = -1
    order      = 2
    up_delay   = -1
  }
}
