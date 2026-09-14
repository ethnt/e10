{
  sops.secrets = {
    prowlarr_api_key = {
      sopsFile = ./secrets.json;
    };
  };
}
