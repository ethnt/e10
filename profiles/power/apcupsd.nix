{
  services.apcupsd = {
    enable = true;
    configText = ''
      UPSCABLE usb
      UPSTYPE usb
      DEVICE
    '';
  };
}
