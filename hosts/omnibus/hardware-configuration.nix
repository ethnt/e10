{
  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "sym53c8xx" "mpt3sas" "nvme" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];
}
