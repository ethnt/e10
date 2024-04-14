{ inputs, lib, ... }:
let inherit (inputs) nixos-generators;
in {
  perSystem = { pkgs, system, ... }: {
    packages = let
      defaultModule = {
        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };

        users.users.root.hashedPassword =
          "$6$u8rGlBrccztA/n7d$DE3m0Ni9hhcAv9K6NjN7YTJhmDdrzUA91QxrsCeM1.5zZRZ6P7FssnbTG7WCFf5IBQN0eIf26FJTGXmzoARaZ/";

        system.stateVersion = "23.11";
      };
    in lib.optionalAttrs pkgs.stdenv.isLinux {
      iso = nixos-generators.nixosGenerate {
        inherit system;
        modules = [ defaultModule ];
        format = "iso";
      };

      sd-aarch64-installer = nixos-generators.nixosGenerate {
        inherit system;
        modules = [ defaultModule ];
        format = "sd-aarch64-installer";
      };
    };
  };
}
