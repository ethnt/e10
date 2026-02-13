{ flake, config, lib, ... }: {
  sops = {
    secrets = {
      sabnzbd_admin_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_api_key = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_nzb_key = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newsgroup_ninja_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newsgroup_ninja_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_eweka_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_eweka_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newshosting_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newshosting_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newsgroup_direct_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newsgroup_direct_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_supernews_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_supernews_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_xsnews_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_xsnews_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };
    };

    templates."sabnzbd/config.ini" = {
      content = flake.lib.generators.toINI {
        globalSection = {
          __version__ = 19;
          __encoding__ = "utf-8";
        };
        sections = {
          misc = {
            inherit (config.services.sabnzbd) port;

            pre_script = "None";
            queue_complete = "";
            queue_complete_pers = 0;
            bandwidth_perc = 100;
            refresh_rate = 1;
            interface_settings = ''
              '{"dateFormat":"fromNow","extraQueueColumns":[],"extraHistoryColumns":[],"displayCompact":false,"displayFullWidth":false,"confirmDeleteQueue":true,"confirmDeleteHistory":true,"keyboardShortcuts":true}'
            '';
            queue_limit = 20;
            config_lock = 0;
            fixed_ports = 1;
            sched_converted = 0;
            notified_new_skin = 2;
            direct_unpack_tested = 1;
            check_new_rel = 1;
            auto_browser = 0;
            language = "en";
            enable_https_verification = 1;
            host = "0.0.0.0";
            https_port = "";
            username = "admin";
            password = config.sops.placeholder.sabnzbd_admin_password;
            bandwidth_max = "";
            cache_limit = "4G";
            web_dir = "Glitter";
            web_color = "Auto";
            https_cert = "server.cert";
            https_key = "server.key";
            https_chain = "";
            enable_https = 0;
            inet_exposure = 4;
            api_key = config.sops.placeholder.sabnzbd_api_key;
            nzb_key = config.sops.placeholder.sabnzbd_nzb_key;
            socks5_proxy_url = "";
            permissions = 777;
            download_dir = "/data/local/tmp/sabnzbd/inter";
            download_free = "8G";
            complete_dir = "/data/local/tmp/sabnzbd/dst";
            complete_free = "8G";
            fulldisk_autoresume = 1;
            script_dir = "";
            nzb_backup_dir = "";
            admin_dir = "/var/lib/sabnzbd/admin/";
            backup_dir = "";
            dirscan_dir = "";
            dirscan_speed = 5;
            password_file = "";
            log_dir = "/var/lib/sabnzbd/logs/";
            max_art_tries = 3;
            load_balancing = 2;
            top_only = 0;
            sfv_check = 1;
            script_can_fail = 0;
            enable_recursive = 1;
            flat_unpack = 1;
            par_option = "";
            pre_check = 0;
            nice = "";
            win_process_prio = 3;
            ionice = "";
            fail_hopeless_jobs = 1;
            fast_fail = 1;
            auto_disconnect = 1;
            no_dupes = 0;
            no_series_dupes = 0;
            series_propercheck = 1;
            pause_on_pwrar = 1;
            ignore_samples = 0;
            deobfuscate_final_filenames = 1;
            auto_sort = "";
            direct_unpack = 1;
            propagation_delay = 0;
            folder_rename = 1;
            replace_spaces = 0;
            replace_underscores = 0;
            replace_dots = 0;
            safe_postproc = 1;
            pause_on_post_processing = 0;
            enable_all_par = 0;
            sanitize_safe = 0;
            cleanup_list = ",";
            unwanted_extensions = ",";
            action_on_unwanted_extensions = 0;
            unwanted_extensions_mode = 0;
            new_nzb_on_failure = 0;
            history_retention = "";
            quota_size = "";
            quota_day = "";
            quota_resume = 0;
            quota_period = "m";
            enable_tv_sorting = 0;
            tv_sort_string = "";
            tv_categories = "tv,";
            enable_movie_sorting = 0;
            movie_sort_string = "";
            movie_sort_extra = "-cd%1";
            movie_categories = "movies,";
            enable_date_sorting = 0;
            date_sort_string = "";
            date_categories = "tv,";
            schedlines = ",";
            rss_rate = 60;
            ampm = 0;
            start_paused = 0;
            preserve_paused_state = 0;
            enable_par_cleanup = 1;
            process_unpacked_par2 = 1;
            enable_unrar = 1;
            enable_unzip = 1;
            enable_7zip = 1;
            enable_filejoin = 1;
            enable_tsjoin = 1;
            overwrite_files = 0;
            ignore_unrar_dates = 0;
            backup_for_duplicates = 1;
            empty_postproc = 0;
            wait_for_dfolder = 0;
            rss_filenames = 0;
            api_logging = 1;
            html_login = 1;
            warn_dupl_jobs = 1;
            helpful_warnings = 1;
            keep_awake = 1;
            tray_icon = 1;
            allow_incomplete_nzb = 0;
            enable_broadcast = 1;
            ipv6_hosting = 0;
            api_warnings = 1;
            no_penalties = 0;
            x_frame_options = 1;
            outgoing_nntp_ip = "";
            allow_old_ssl_tls = 0;
            rss_odd_titles = "nzbindex.nl/, nzbindex.com/, nzbclub.com/";
            quick_check_ext_ignore = "nfo, sfv, srr";
            req_completion_rate = "100.2";
            selftest_host = "self-test.sabnzbd.org";
            movie_rename_limit = "100M";
            episode_rename_limit = "20M";
            size_limit = 0;
            direct_unpack_threads = 3;
            history_limit = 10;
            wait_ext_drive = 5;
            max_foldername_length = 246;
            nomedia_marker = "";
            ipv6_servers = 1;
            url_base = "/sabnzbd";
            host_whitelist = "htpc,";
            local_ranges = ",";
            max_url_retries = 10;
            downloader_sleep_time = 10;
            num_simd_decoders = 2;
            ssdp_broadcast_interval = 15;
            ext_rename_ignore = ",";
            email_server = "";
            email_to = ",";
            email_from = "";
            email_account = "";
            email_pwd = "";
            email_endjob = 0;
            email_full = 0;
            email_dir = "";
            email_rss = 0;
            email_cats = "*,";
            sorters_converted = 1;
            enable_season_sorting = 1;
            receive_threads = 2;
            switchinterval = 5.0e-3;
            end_queue_script = "None";
            no_smart_dupes = 0;
            dupes_propercheck = 1;
            enable_multipar = 1;
            verify_xff_header = 0;
            history_retention_option = "all";
            history_retention_number = 1;
            disable_archive = 0;
            ipv6_staging = 0;
            config_conversion_version = 4;
            disable_par2cmdline = 0;
            unrar_parameters = "";
          };
          logging = {
            log_level = 2;
            max_log_size = 5242880;
            log_backups = 1;
          };
          ncenter = {
            ncenter_enable = 0;
            ncenter_cats = "*,";
            ncenter_prio_startup = 0;
            ncenter_prio_download = 0;
            ncenter_prio_pause_resume = 0;
            ncenter_prio_pp = 0;
            ncenter_prio_complete = 0;
            ncenter_prio_failed = 0;
            ncenter_prio_disk_full = 0;
            ncenter_prio_new_login = 0;
            ncenter_prio_warning = 0;
            ncenter_prio_error = 0;
            ncenter_prio_queue_done = 0;
            ncenter_prio_other = 0;
            ncenter_prio_quota = 1;
          };
          acenter = {
            acenter_enable = 0;
            acenter_cats = "*,";
            acenter_prio_startup = 0;
            acenter_prio_download = 0;
            acenter_prio_pause_resume = 0;
            acenter_prio_pp = 0;
            acenter_prio_complete = 0;
            acenter_prio_failed = 0;
            acenter_prio_disk_full = 0;
            acenter_prio_new_login = 0;
            acenter_prio_warning = 0;
            acenter_prio_error = 0;
            acenter_prio_queue_done = 0;
            acenter_prio_other = 0;
            acenter_prio_quota = 1;
          };
          ntfosd = {
            ntfosd_enable = 0;
            ntfosd_cats = "*,";
            ntfosd_prio_startup = 0;
            ntfosd_prio_download = 0;
            ntfosd_prio_pause_resume = 0;
            ntfosd_prio_pp = 0;
            ntfosd_prio_complete = 0;
            ntfosd_prio_failed = 0;
            ntfosd_prio_disk_full = 0;
            ntfosd_prio_new_login = 0;
            ntfosd_prio_warning = 0;
            ntfosd_prio_error = 0;
            ntfosd_prio_queue_done = 0;
            ntfosd_prio_other = 0;
            ntfosd_prio_quota = 1;
          };
          prowl = {
            prowl_enable = 0;
            prowl_cats = "*,";
            prowl_apikey = "";
            prowl_prio_startup = -3;
            prowl_prio_download = -3;
            prowl_prio_pause_resume = -3;
            prowl_prio_pp = -3;
            prowl_prio_complete = 0;
            prowl_prio_failed = 1;
            prowl_prio_disk_full = 1;
            prowl_prio_new_login = -3;
            prowl_prio_warning = -3;
            prowl_prio_error = -3;
            prowl_prio_queue_done = 0;
            prowl_prio_other = 0;
            prowl_prio_quota = 0;
          };
          pushover = {
            pushover_token = "";
            pushover_userkey = "";
            pushover_device = "";
            pushover_emergency_expire = 3600;
            pushover_emergency_retry = 60;
            pushover_enable = 0;
            pushover_cats = "*,";
            pushover_prio_startup = -3;
            pushover_prio_download = -2;
            pushover_prio_pause_resume = -2;
            pushover_prio_pp = -3;
            pushover_prio_complete = -1;
            pushover_prio_failed = -1;
            pushover_prio_disk_full = 1;
            pushover_prio_new_login = -3;
            pushover_prio_warning = 1;
            pushover_prio_error = 1;
            pushover_prio_queue_done = -1;
            pushover_prio_other = -1;
            pushover_prio_quota = -1;
          };
          pushbullet = {
            pushbullet_enable = 0;
            pushbullet_cats = "*,";
            pushbullet_apikey = "";
            pushbullet_device = "";
            pushbullet_prio_startup = 0;
            pushbullet_prio_download = 0;
            pushbullet_prio_pause_resume = 0;
            pushbullet_prio_pp = 0;
            pushbullet_prio_complete = 1;
            pushbullet_prio_failed = 1;
            pushbullet_prio_disk_full = 1;
            pushbullet_prio_new_login = 0;
            pushbullet_prio_warning = 0;
            pushbullet_prio_error = 0;
            pushbullet_prio_queue_done = 0;
            pushbullet_prio_other = 1;
            pushbullet_prio_quota = 1;
          };
          nscript = {
            nscript_enable = 0;
            nscript_cats = "*,";
            nscript_script = "None";
            nscript_parameters = "";
            nscript_prio_startup = 1;
            nscript_prio_download = 0;
            nscript_prio_pause_resume = 0;
            nscript_prio_pp = 0;
            nscript_prio_complete = 1;
            nscript_prio_failed = 1;
            nscript_prio_disk_full = 1;
            nscript_prio_new_login = 0;
            nscript_prio_warning = 0;
            nscript_prio_error = 0;
            nscript_prio_queue_done = 1;
            nscript_prio_other = 1;
            nscript_prio_quota = 1;
          };
          apprise = {
            apprise_enable = 0;
            apprise_cats = "*,";
            apprise_urls = "";
            apprise_target_startup = "";
            apprise_target_startup_enable = 0;
            apprise_target_download = "";
            apprise_target_download_enable = 0;
            apprise_target_pause_resume = "";
            apprise_target_pause_resume_enable = 0;
            apprise_target_pp = "";
            apprise_target_pp_enable = 0;
            apprise_target_complete = "";
            apprise_target_complete_enable = 1;
            apprise_target_failed = "";
            apprise_target_failed_enable = 1;
            apprise_target_disk_full = "";
            apprise_target_disk_full_enable = 0;
            apprise_target_new_login = "";
            apprise_target_new_login_enable = 1;
            apprise_target_warning = "";
            apprise_target_warning_enable = 0;
            apprise_target_error = "";
            apprise_target_error_enable = 0;
            apprise_target_queue_done = "";
            apprise_target_queue_done_enable = 0;
            apprise_target_other = "";
            apprise_target_other_enable = 1;
            apprise_target_quota = "";
            apprise_target_quota_enable = 1;
          };
          servers = {
            "news-us.newsgroup.ninja" = {
              displayname = "news-us.newsgroup.ninja";
              host = "news-us.newsgroup.ninja";
              port = 563;
              timeout = 60;
              username =
                config.sops.placeholder.sabnzbd_newsgroup_ninja_username;
              password =
                config.sops.placeholder.sabnzbd_newsgroup_ninja_password;
              connections = 40;
              ssl = 1;
              ssl_verify = 3;
              ssl_ciphers = "";
              enable = 1;
              required = 0;
              optional = 0;
              retention = 0;
              expire_date = "2026-10-29";
              quota = "";
              usage_at_start = 0;
              priority = 0;
              notes = "";
            };
            "news.supernews.com" = {
              name = "news.supernews.com";
              displayname = "news.supernews.com";
              host = "news.supernews.com";
              port = 119;
              timeout = 60;
              username = config.sops.placeholder.sabnzbd_supernews_username;
              password = config.sops.placeholder.sabnzbd_supernews_password;
              connections = 15;
              ssl = 0;
              ssl_verify = 3;
              ssl_ciphers = "";
              enable = 0;
              required = 0;
              optional = 0;
              retention = 0;
              expire_date = "";
              quota = "";
              usage_at_start = 0;
              priority = 0;
              notes = "";
            };
            "reader.xsnews.nl" = {
              name = "reader.xsnews.nl";
              displayname = "reader.xsnews.nl";
              host = "reader.xsnews.nl";
              port = 563;
              timeout = 60;
              username = config.sops.placeholder.sabnzbd_xsnews_username;
              password = config.sops.placeholder.sabnzbd_xsnews_password;
              connections = 15;
              ssl = 1;
              ssl_verify = 3;
              ssl_ciphers = "";
              enable = 0;
              required = 0;
              optional = 0;
              retention = 0;
              expire_date = "";
              quota = "";
              usage_at_start = 0;
              priority = 0;
              notes = "";
            };
            "news.newshosting.com" = {
              name = "news.newshosting.com";
              displayname = "news.newshosting.com";
              host = "news.newshosting.com";
              port = 563;
              timeout = 60;
              username = config.sops.placeholder.sabnzbd_newshosting_username;
              password = config.sops.placeholder.sabnzbd_newshosting_password;
              connections = 100;
              ssl = 1;
              ssl_verify = 3;
              ssl_ciphers = "";
              enable = 1;
              required = 0;
              optional = 0;
              retention = 0;
              expire_date = "2026-08-29";
              quota = "";
              usage_at_start = 0;
              priority = 0;
              notes = "";
            };
            "news.newsgroupdirect.com" = {
              name = "news.newsgroupdirect.com";
              displayname = "NewsgroupDirect";
              host = "news.newsgroupdirect.com";
              port = 563;
              timeout = 60;
              username =
                config.sops.placeholder.sabnzbd_newsgroup_direct_username;
              password =
                config.sops.placeholder.sabnzbd_newsgroup_direct_password;
              connections = 8;
              ssl = 1;
              ssl_verify = 3;
              ssl_ciphers = "";
              enable = 1;
              required = 0;
              optional = 0;
              retention = 0;
              expire_date = "";
              quota = "4000G";
              usage_at_start = 0;
              priority = 1;
              notes = "";
            };
            "news.eweka.nl" = {
              name = "news.eweka.nl";
              displayname = "news.eweka.nl";
              host = "news.eweka.nl";
              port = 563;
              timeout = 60;
              username = config.sops.placeholder.sabnzbd_eweka_username;
              password = config.sops.placeholder.sabnzbd_eweka_password;
              connections = 50;
              ssl = 1;
              ssl_verify = 3;
              ssl_ciphers = "";
              enable = 1;
              required = 0;
              optional = 0;
              retention = 0;
              expire_date = "2027-05-13";
              quota = "";
              usage_at_start = 0;
              priority = 0;
              notes = "";
            };
          };
          categories = {
            "*" = {
              name = "*";
              order = 0;
              pp = 3;
              script = "None";
              dir = "";
              newzbin = "";
              priority = 0;
            };
            movies = {
              name = "movies";
              order = 0;
              pp = "";
              script = "Default";
              dir = "";
              newzbin = "";
              priority = -100;
            };
            tv = {
              name = "tv";
              order = 0;
              pp = "";
              script = "Default";
              dir = "";
              newzbin = "";
              priority = -100;
            };
            audio = {
              name = "audio";
              order = 0;
              pp = "";
              script = "Default";
              dir = "";
              newzbin = "";
              priority = -100;
            };
            software = {
              name = "software";
              order = 0;
              pp = "";
              script = "Default";
              dir = "";
              newzbin = "";
              priority = -100;
            };
            prowlarr = {
              name = "prowlarr";
              order = 1;
              pp = "";
              script = "Default";
              dir = "";
              newzbin = "";
              priority = -100;
            };
            books = {
              name = "books";
              order = 2;
              pp = "";
              script = "Default";
              dir = "";
              newzbin = "";
              priority = -100;
            };
          };
        };
      };
      owner = config.services.sabnzbd.user;
      restartUnits = [ "sabnzbd.service" ];
    };
  };

  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    configFile = config.sops.templates."sabnzbd/config.ini".path;
  };

  systemd.services.sabnzbd.serviceConfig.ExecStart = lib.mkOverride 10 "${
      lib.getExe' config.services.sabnzbd.package "sabnzbd"
    } -d -f ${config.services.sabnzbd.configFile} --disable-file-log";

  systemd.tmpfiles.rules = [
    "d '/data/local/tmp/sabnzbd/inter' 0777 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
    "d '/data/local/tmp/sabnzbd/dst' 0777 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
  ];

  services.prometheus.exporters.exportarr-sabnzbd = {
    enable = true;
    url = "https://sabnzbd.e10.camp";
    openFirewall = true;
    apiKeyFile = config.sops.secrets.sabnzbd_api_key.path;
    port = 9712;
  };
}
