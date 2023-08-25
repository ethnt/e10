{ inputs, ... }: {
  imports = [ inputs.nixos-hardware.nixosModules.common-cpu-intel ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };
}
