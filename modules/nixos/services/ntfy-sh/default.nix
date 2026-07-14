{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.ntfy-sh;
in
{
  options.services.ntfy-sh = {
    baseUrl = mkOption {
      type = types.str;
      description = "Public facing base URL of the service `(e.g. https://ntfy.sh)`";
    };

    behindProxy = mkOption {
      type = types.bool;
      description = "If set, use forwarded header (e.g. X-Forwarded-For, X-Client-IP) to determine visitor IP address (for rate limiting)";
      default = false;
    };

    attachmentCacheDir = mkOption {
      type = types.path;
      description = "Cache directory for attached files, or S3 URL for object storage";
      default = "/var/lib/ntfy-sh/attachments";
    };

    cacheFile = mkOption {
      type = types.path;
      description = "If set, messages are cached in a local SQLite database instead of only in-memory. This allows for service restarts without losing messages in support of the `since=` parameter";
      default = "/var/lib/ntfy-sh/cache-file.db";
    };

    upstreamBaseUrl = mkOption {
      type = types.nullOr types.str;
      description = "Forward poll request to an upstream server, this is needed for iOS push notifications for self-hosted servers";
      default = "https://ntfy.sh";
    };

    auth = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Authentication for ntfy";

          defaultAccess = mkOption {
            type = types.enum [
              "read-write"
              "read-only"
              "write-only"
              "deny-all"
            ];
            description = "";
            default = "deny-all";
          };

          authFile = mkOption {
            type = types.path;
            description = "Auth database file used for access control (SQLite). If set, enables authentication and access control. Not required if database-url is set";
            default = "/var/lib/ntfy-sh/user.db";
          };

          admin = mkOption {
            type = types.submodule {
              options = {
                username = mkOption {
                  type = types.str;
                  description = "";
                  default = "admin";
                };

                passwordFile = mkOption {
                  type = types.nullOr types.str;
                  description = "";
                  default = null;
                };
              };
            };
          };

          extraUsers = lib.mkOption {
            type = lib.types.listOf (
              lib.types.submodule {
                options = {
                  username = lib.mkOption {
                    type = lib.types.str;
                    description = "Username. Must match ntfy's accepted characters (alphanumerics, -, _).";
                  };
                  passwordFile = lib.mkOption {
                    type = lib.types.str;
                    description = "Path to a file containing the user's password.";
                  };
                  role = lib.mkOption {
                    type = lib.types.enum [
                      "admin"
                      "user"
                    ];
                    default = "user";
                    description = ''
                      ntfy role. 'user' is subject to defaultAccess plus explicit
                      grants; 'admin' has unrestricted access regardless of grants.
                    '';
                  };
                  grants = lib.mkOption {
                    type = lib.types.listOf (
                      lib.types.submodule {
                        options = {
                          topic = lib.mkOption {
                            type = lib.types.str;
                            description = ''
                              Topic name. ntfy supports wildcards via '*' (e.g.
                              'veil-*' grants on all veil-prefixed topics).
                            '';
                          };
                          access = lib.mkOption {
                            type = lib.types.enum [
                              "read-write"
                              "read-only"
                              "write-only"
                              "deny-all"
                            ];
                            description = "Access level on this topic.";
                          };
                        };
                      }
                    );
                    description = "Per-topic ACL grants applied via 'ntfy access'";
                    default = [ ];
                  };
                };
              }
            );
            description = "Additional, non-admin ntfy users with optional per-topic ACL grants";
            default = [ ];
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (
    let
      adminCredentialId = "admin-password";
      extraCredentialId = user: "extrauser-${user.username}-password";

      adminCredentialArg = optional (
        cfg.auth.admin.passwordFile != null
      ) "${adminCredentialId}:${cfg.auth.admin.passwordFile}";
      extraCredArgs = map (u: "${extraCredentialId u}:${u.passwordFile}") cfg.auth.extraUsers;
      provisionUsers = pkgs.writeShellApplication {
        name = "ntfy-sh-provision-users";
        runtimeInputs = with pkgs; [
          ntfy-sh
          coreutils
          gnugrep
        ];
        text = ''
          set -euo pipefail

          export NTFY_AUTH_FILE="${cfg.auth.authFile}"

          if [ -z "''${CREDENTIALS_DIRECTORY:-}" ]; then
            echo "ntfy-sh-provision-users: CREDENTIALS_DIRECTORY not set" >&2
            exit 1
          fi

          ${lib.optionalString (cfg.auth.admin.passwordFile != null) ''
            NTFY_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/${adminCredentialId}")
            export NTFY_PASSWORD

            if ntfy user add --role=admin ${cfg.auth.admin.username} 2>/dev/null; then
              echo "Created ntfy admin user '${cfg.auth.admin.username}'"
            else
              echo "Admin user '${cfg.auth.admin.username}' already exists, updating password..."
              ntfy user change-pass ${cfg.auth.admin.username}
            fi

            unset NTFY_PASSWORD
          ''}

          ${lib.concatMapStrings (user: ''
            echo "Setting up ntfy user '${user.username}' (role=${user.role})..."

            NTFY_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/${extraCredentialId user}")
            export NTFY_PASSWORD

            if ntfy user add --role=${user.role} ${user.username} 2>/dev/null; then
              echo "Created ntfy user '${user.username}'"
            else
              ntfy user change-pass ${user.username}
            fi

            unset NTFY_PASSWORD

            ${lib.concatMapStrings (grant: ''
              ntfy access ${user.username} '${grant.topic}' ${grant.access}
            '') user.grants}
          '') cfg.auth.extraUsers}

          echo "ntfy user setup complete"
        '';
      };
      needsProvisioning = cfg.auth.enable && (cfg.auth.admin.passwordFile != null);
    in
    {
      services.ntfy-sh = {
        settings = {
          base-url = cfg.baseUrl;
          behind-proxy = cfg.behindProxy;
          attachment-cache-dir = cfg.attachmentCacheDir;
          cache-file = cfg.cacheFile;
          upstream-base-url = cfg.upstreamBaseUrl;
        }
        // optionalAttrs cfg.auth.enable {
          auth-file = cfg.auth.authFile;
          auth-default-access = cfg.auth.defaultAccess;
          enable-login = true;
        };
      };

      systemd.services.ntfy-sh.serviceConfig = mkIf needsProvisioning {
        ExecStartPre = [ "${provisionUsers}/bin/ntfy-sh-provision-users" ];
        LoadCredential = adminCredentialArg ++ extraCredArgs;
      };
    }
  );
}
