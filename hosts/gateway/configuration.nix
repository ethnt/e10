{ suites, ... }: {
  imports = with suites; core ++ web ++ aws ++ [ ./profiles/nginx ];

  system.stateVersion = "24.05";
}
