{ config, hosts, pkgs, ... }:
let
  cameraAddress = "192.168.1.102";
  cameraUsername = "viewer";
  cameraPassword = "{FRIGATE_KITCHEN_PASSWORD}";
  configFile = (pkgs.formats.yaml { }).generate "frigate.yml" {
    auth.enabled = true;
    tls.enabled = false;
    go2rtc = {
      streams.kitchen = [
        "ffmpeg:rtsp://${cameraUsername}:\${FRIGATE_KITCHEN_PASSWORD}@${cameraAddress}:554/stream1"
        "ffmpeg:kitchen#audio=aac"
        "tapo://admin:{FRIGATE_TAPO_SHA256}@${cameraAddress}"
      ];
      api.origin = "*";
    };
    mqtt = {
      enabled = true;
      host = hosts.controller.config.networking.hostName;
      user = "frigate";
      password = "{FRIGATE_MQTT_PASSWORD}";
    };
    detectors = { onnx_0 = { type = "onnx"; }; };
    model = {
      model_type = "yolox";
      width = 416;
      height = 416;
      input_dtype = "float_denorm";
      input_tensor = "nchw";
      path = "/config/model_cache/yolo_tiny.onnx";
      labelmap_path = "/labelmap/coco-80.txt";
    };
    cameras.kitchen = {
      ffmpeg = {
        hwaccel_args = "preset-nvidia";
        output_args.record = "preset-record-generic-audio-copy";
        inputs = [{
          path = "rtsp://127.0.0.1:8554/kitchen";
          input_args = "preset-rtsp-restream";
          roles = [ "audio" "detect" "record" ];
        }];
      };
      onvif = {
        host = cameraAddress;
        port = 2020;
        user = cameraUsername;
        password = cameraPassword;
      };
      record = {
        enabled = true;
        retain.days = 0;
        alerts = {
          retain = {
            days = 30;
            mode = "motion";
          };
        };
        detections = {
          retain = {
            days = 30;
            mode = "motion";
          };
        };
      };
    };
    detect.enabled = true;
    objects.filters.person.min_score = 0.8;
  };
in {
  sops = {
    secrets = {
      frigate_mqtt_password.sopsFile = ./secrets.json;
      frigate_kitchen_password.sopsFile = ./secrets.json;
      frigate_tapo_sha256.sopsFile = ./secrets.json;
    };

    templates."frigate/environment_file" = {
      content = ''
        FRIGATE_MQTT_PASSWORD=${config.sops.placeholder.frigate_mqtt_password}
        FRIGATE_KITCHEN_PASSWORD=${config.sops.placeholder.frigate_kitchen_password}
        FRIGATE_TAPO_SHA256=${config.sops.placeholder.frigate_tapo_sha256}
      '';
      mode = "0777";
    };
  };

  systemd.tmpfiles.settings."20-frigate-media-dir" = {
    mediaDir = {
      "d" = {
        user = config.virtualisation.oci-containers.backend;
        group = config.virtualisation.oci-containers.backend;
        mode = "0777";
      };
    };
  };

  virtualisation.oci-containers.containers.frigate = {
    image = "ghcr.io/blakeblackshear/frigate:stable-tensorrt";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/var/lib/frigate:/config"
      "${configFile}:/config/config.yaml:ro"
      "/mnt/files/services/frigate:/media/frigate"
    ];
    devices = [ "/dev/dri:/dev/dri" ];
    environmentFiles =
      [ config.sops.templates."frigate/environment_file".path ];
    ports = [
      "8971:8971"
      "8554:8554"
      "5000:5000"
      "8555:8555/tcp"
      "8555:8555/udp"
      "1984:1984"
    ];
    environment = {
      NVIDIA_DRIVER_CAPABILITIES = "compute,video,utility";
      NVIDIA_VISIBLE_DEVICES = "all";
    };
    extraOptions = [
      "--shm-size=1024mb"
      "--cap-add=SYS_ADMIN"
      "--device=nvidia.com/gpu=all"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 1984 5000 8090 8971 ];
}
