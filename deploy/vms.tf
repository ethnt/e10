resource "proxmox_vm_qemu" "htpc" {
  name        = "htpc"
  target_node = "pve"
  vmid        = 201
  agent       = 1
  desc        = "htpc.e10.network"

  bios   = "seabios"
  onboot = true

  clone      = "template"
  full_clone = true

  memory = 32768

  cores = 8

  disk {
    backup             = 0
    cache              = "none"
    file               = "vm-201-disk-0"
    format             = "raw"
    iops               = 0
    iops_max           = 0
    iops_max_length    = 0
    iops_rd            = 0
    iops_rd_max        = 0
    iops_rd_max_length = 0
    iops_wr            = 0
    iops_wr_max        = 0
    iops_wr_max_length = 0
    iothread           = 0
    mbps               = 0
    mbps_rd            = 0
    mbps_rd_max        = 0
    mbps_wr            = 0
    mbps_wr_max        = 0
    replicate          = 0
    size               = "64G"
    slot               = 0
    ssd                = 0
    storage            = "local-lvm"
    type               = "virtio"
    volume             = "local-lvm:vm-201-disk-0"
  }

  network {
    bridge    = "vmbr0"
    firewall  = true
    link_down = false
    macaddr   = "8A:73:A7:C2:29:E2"
    model     = "virtio"
    mtu       = 0
    queues    = 0
    rate      = 0
    tag       = -1
  }
}

resource "proxmox_vm_qemu" "matrix" {
  name        = "matrix"
  target_node = "pve"
  vmid        = 202
  agent       = 1
  desc        = "matrix.e10.network"

  bios   = "seabios"
  onboot = true

  clone      = "template"
  full_clone = true

  memory = 8192

  cores = 4

  disk {
    backup             = 0
    cache              = "none"
    file               = "vm-202-disk-0"
    format             = "raw"
    iops               = 0
    iops_max           = 0
    iops_max_length    = 0
    iops_rd            = 0
    iops_rd_max        = 0
    iops_rd_max_length = 0
    iops_wr            = 0
    iops_wr_max        = 0
    iops_wr_max_length = 0
    iothread           = 0
    mbps               = 0
    mbps_rd            = 0
    mbps_rd_max        = 0
    mbps_wr            = 0
    mbps_wr_max        = 0
    replicate          = 0
    size               = "16G"
    slot               = 0
    ssd                = 0
    storage            = "local-lvm"
    type               = "virtio"
    volume             = "local-lvm:vm-202-disk-0"
  }

  network {
    bridge    = "vmbr0"
    firewall  = true
    link_down = false
    macaddr   = "22:AA:52:DA:6C:DD"
    model     = "virtio"
    mtu       = 0
    queues    = 0
    rate      = 0
    tag       = -1
  }
}
