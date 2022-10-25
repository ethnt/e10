resource "proxmox_vm_qemu" "matrix" {
  name        = "matrix"
  target_node = "pve"
  vmid        = 202
  agent       = 1

  bios   = "seabios"
  onboot = true

  clone      = "template"
  full_clone = true

  memory = 2048

  cores = 2
}
