let port = 8555;
in {
  services.go2rtc = {
    enable = true;
    settings = {
      streams = { webrtc-eufy = "webrtc:http://localhost:3000"; };
      rtsp.listen = "0.0.0.0:${toString port}";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 8555 ];
    allowedUDPPorts = [ 8555 ];
  };
}
