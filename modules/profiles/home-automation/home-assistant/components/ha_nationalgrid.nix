{
  fetchFromGitHub,
  home-assistant,
  buildHomeAssistantComponent,
  py-nationalgrid,
}:

let
  pythonPkgs = home-assistant.python3Packages;
in
buildHomeAssistantComponent rec {
  owner = "virtitnerd";
  domain = "national_grid_us";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "virtitnerd";
    repo = "ha_nationalgrid";
    tag = "v${version}";
    hash = "sha256-+2/x8mXt2gwb5V7kr5ns35HAbBsA99zUiXS7+k66igA=";
  };

  dependencies = with pythonPkgs; [
    colorlog
    homeassistant
    ruff
    py-nationalgrid
  ];
}
