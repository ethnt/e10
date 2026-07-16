{ config, ... }: {
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
}
