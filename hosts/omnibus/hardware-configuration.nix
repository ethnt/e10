{
  boot = {
    initrd.availableKernelModules =
      [ "ata_piix" "uhci_hcd" "sym53c8xx" "mpt3sas" "nvme" "sd_mod" "sr_mod" ];

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  swapDevices = [ ];
}
