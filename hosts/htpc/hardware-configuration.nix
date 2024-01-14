{
  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "ehci_pci"
      "nvme"
      "sd_mod"
      "sr_mod"
      "uhci_hcd"
      "virtio_pci"
      "virtio_scsi"
    ];

    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  swapDevices = [ ];
}
