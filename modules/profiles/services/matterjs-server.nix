{
  services.matterjs-server = {
    enable = true;
    extraArgs = [
      "--vendorid=4939" # Use Home Assistant's vendor ID
    ];
    openFirewall = true;
  };
}
