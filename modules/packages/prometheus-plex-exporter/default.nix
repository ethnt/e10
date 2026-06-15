{ lib, buildGoModule, fetchFromGitHub, go_1_26 }:

buildGoModule.override { go = go_1_26; } rec {
  pname = "prometheus-plex-exporter";
  version = "3e7a4da";

  src = fetchFromGitHub {
    owner = "timothystewart6";
    repo = "prometheus-plex-exporter";
    rev = version;
    hash = "sha256-jOMv8cYzhJd3HQ/fbL8X/MTp3MTRidAVM7ojqxYxgNg=";
  };

  vendorHash = null;

  subPackages = [ "cmd/prometheus-plex-exporter" ];

  meta = with lib; {
    description = "Export metrics from your Plex Media Server";
    homepage = "https://github.com/jsclayton/prometheus-plex-exporter";
    license = licenses.agpl3Plus;
    platforms = platforms.all;
    mainProgram = "prometheus-plex-exporter";
  };
}
