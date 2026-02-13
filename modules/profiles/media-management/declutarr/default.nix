{ config, lib, ... }: {
  sops.templates."declutarr/config.yml" = {
    content = lib.generators.toYAML { } {
      general = {
        log_level = "INFO";
        test_run = false;
        timer = 10;
      };

      job_defaults = {
        max_strikes = 3;
        min_days_between_searches = 1;
        max_concurrent_searches = 3;
      };

      jobs = {
        remove_bad_files = true;
        remove_failed_imports = {
          message_patterns = [
            "No files found are eligible for import*"
            "No video files were found in the selected folder"
            "Not a Custom Format upgrade for existing*"
            "Not an upgrade for existing*"
            "One or more episodes expected in this release were not imported or missing from the release"
            "Unable to determine if file is a sample"
            "Episode file on disk contains more episodes than this file contains"
          ];
        };
        remove_metadata_missing = true;
        remove_missing_files = true;
        remove_orphans = true;
        remove_unmonitored = true;
      };

      instances = {
        sonarr = [{
          base_url = "https://sonarr.e10.camp";
          api_key = config.sops.placeholder.sonarr_api_key;
        }];

        radarr = [{
          base_url = "https://radarr.e10.camp";
          api_key = config.sops.placeholder.radarr_api_key;
        }];
      };

      download_clients = {
        sabnzbd = [{
          base_url = "https://sabnzbd.e10.camp";
          api_key = config.sops.placeholder.sabnzbd_api_key;
        }];
      };
    };
    owner = config.services.declutarr.user;
    inherit (config.services.declutarr) group;
    mode = "0700";
  };

  services.declutarr = {
    enable = true;
    configFile = config.sops.templates."declutarr/config.yml".path;
  };
}
