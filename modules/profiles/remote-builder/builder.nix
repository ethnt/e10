{ config, profiles, ... }: {
  imports = [ profiles.users.builder ];

  nix.settings.trusted-users = [ config.users.users.builder.name ];
}
