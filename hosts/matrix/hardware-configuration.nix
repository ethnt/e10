{
  boot = {
    initrd.availableKernelModules =
      [ "ata-piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];

    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  swapDevices = [ ];
}
