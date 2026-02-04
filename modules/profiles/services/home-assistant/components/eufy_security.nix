{ fetchFromGitHub, home-assistant, buildHomeAssistantComponent }:

let pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent rec {
  owner = "fuatakgun";
  domain = "eufy_security";
  version = "8.2.2";

  src = fetchFromGitHub {
    owner = "fuatakgun";
    repo = "eufy_security";
    tag = "v${version}";
    hash = "sha256-506rbpkwGPXyx7OQgLNLnbGsqxkfIxUa808J1PA3s0E=";
  };

  dependencies = with pythonPkgs; [ websocket-client aiortsp ];
}
