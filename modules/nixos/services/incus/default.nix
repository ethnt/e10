{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.virtualisation.incus;
  format = pkgs.formats.yaml { };

  isLocal = instance: lib.isDerivation instance.image;

  imageAlias = instance:
    if isLocal instance then instance.name else instance.image;

  applyDir = pkgs.linkFarm "incus-apply-config" (map (instance: {
    name = "${instance.name}.yml";
    path = format.generate "${instance.name}.yml" {
      inherit (instance) kind;
      inherit (instance) name;
      image = imageAlias instance;
      inherit (instance) profiles;
      inherit (instance) vm;
      inherit (instance) config;
      inherit (instance) devices;
    };
  }) cfg.instances);

  importScript = lib.concatMapStrings (instance:
    lib.optionalString (isLocal instance) ''
      if ! incus image info ${
        lib.escapeShellArg instance.name
      } &>/dev/null; then
        incus image import \
          ${instance.metadata}/tarball/*.tar.xz \
          ${instance.image}/nixos.qcow2 \
          --alias ${lib.escapeShellArg instance.name}
      fi
    '') cfg.instances;

  flatten = prefix: attrs:
    lib.foldlAttrs (acc: name: value:
      let path = if prefix == "" then name else "${prefix}.${name}";
      in acc // (if builtins.isAttrs value then
        flatten path value
      else {
        ${path} = value;
      })) { } attrs;
in {
  options.virtualisation.incus = {
    instances = mkOption {
      type = types.listOf (types.submodule {
        options = {
          kind = mkOption {
            type = types.str;
            default = "instance";
          };

          name = mkOption {
            type = types.str;
            description = "Name of the instance";
          };

          image = mkOption {
            type = types.either types.str types.package;
            description =
              "Image to use (either a local QEMU image or a reference to a remote image)";
          };

          metadata = mkOption {
            type = types.nullOr types.package;
            default = null;
            description =
              "Image metadata derivation (required when image is a local derivation).";
          };

          profiles = mkOption {
            type = types.listOf types.str;
            description =
              "Which Incus profiles should be used for this instance";
            default = [ "default" ];
          };

          vm = mkOption {
            type = types.bool;
            description =
              "If this instance should be a VM instead of a container";
            default = false;
          };

          config = mkOption {
            inherit (format) type;
            description = "Freeform configuration for this instance";
            default = { };
          };

          devices = mkOption {
            inherit (format) type;
            description = "Freeform device overrides for this instance";
            default = { };
          };
        };
      });
      default = [ ];
    };

    config = mkOption {
      inherit (format) type;
      description = "Configuration settings to set";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    assertions = map (instance: {
      assertion = !isLocal instance || instance.metadata != null;
      message = ''
        virtualisation.incus.instances: instance "${instance.name}" has a local image derivation but no metadata set.'';
    }) cfg.instances;

    systemd.services.incus-apply = {
      description = "Apply Incus configuration";
      after = [ "incus.service" ];
      wants = [ "incus.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "incus-apply-exec";
          runtimeInputs =
            [ config.virtualisation.incus.package pkgs.incus-apply ];
          text = let
            configLines = lib.concatStringsSep "\n" (lib.mapAttrsToList
              (k: v: "incus config set ${lib.escapeShellArg "${k}=${v}"}")
              (flatten "" cfg.config));
          in ''
            ${configLines}

            ${importScript}

            incus-apply ${applyDir} --yes --quiet
          '';
        });
      };
    };
  };
}
