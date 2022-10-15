{ channel, ... }: {
  nix.nixPath =
    [ "nixpkgs=${channel.input}" "nixos-config=${../lib/compat/nixos}" ];
}
