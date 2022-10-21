resource "proxmox_vm_qemu" "errata-v2" {
  name        = "errata-camp"
  target_node = "pve"
  vmid        = 202
  bios        = "seabios"
  clone       = "template"
  full_clone  = true
  agent       = 1
  memory      = 2048

  # usb {
  #   host = "051d:0002"
  #   usb3 = false
  # }

  # usb {
  #   host = "04f9:0061"
  #   usb3 = false
  # }
}
