{
  sops.secrets = {
    aws_access_key_id = {
      sopsFile = ./secrets.json;
    };

    aws_secret_access_key = {
      sopsFile = ./secrets.json;
    };
  };
}
