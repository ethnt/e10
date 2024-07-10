{ suites, ... }: {
  imports = with suites; core ++ web ++ aws ++ [ ./profiles/nginx.nix ];

  system.stateVersion = "24.05";
}
