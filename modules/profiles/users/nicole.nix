{ pkgs, lib, ... }: {
  users.users.nicole = {
    hashedPassword =
      "$y$j9T$6mx45DR3tlbVi8S6mtON3/$LxCAD21muEs91l2SD3mizEyOwkA6/PAn6cUuvAsmLMC";
    isNormalUser = true;
    shell = lib.getExe' pkgs.shadow "nologin";
  };
}
