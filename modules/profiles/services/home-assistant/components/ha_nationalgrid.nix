{ fetchFromGitHub, home-assistant, buildHomeAssistantComponent, aionatgrid }:

let pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent rec {
  owner = "RyanMorash";
  domain = "national_grid";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "RyanMorash";
    repo = "ha_nationalgrid";
    tag = "v${version}";
    hash = "sha256-dw0kRmQ0duyHDmxLXhdcwGXC8uvo0bda9wVpJ1WtmG0=";
  };

  dependencies = with pythonPkgs; [
    colorlog
    homeassistant
    pip
    ruff
    aionatgrid
  ];
}
