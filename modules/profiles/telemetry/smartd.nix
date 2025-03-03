{
  services.smartd = {
    enable = true;
    notifications = {
      test = true;
      mail = {
        enable = true;
        sender = "admin@e10.camp";
        recipient = "e10@turkeltaub.dev";
      };
    };
  };
}
