{
  services.bentopdf = {
    enable = true;
    domain = "pdf.e10.camp";

    nginx = {
      enable = true;
      virtualHost = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 4152;
          }
        ];
      };
    };
  };
}
