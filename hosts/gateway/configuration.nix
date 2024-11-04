{ suites, ... }: {
  imports = with suites; core ++ web ++ aws ++ [ ./profiles/nginx ];

  deployment.tags = [ "@external" ];

  system.stateVersion = "24.05";
}
