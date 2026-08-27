{ buildGo126Module, fetchFromGitHub, nix-update-script }:

buildGo126Module rec {
  pname = "incus-apply";
  name = "incus-apply";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "abiosoft";
    repo = "incus-apply";
    tag = "v${version}";
    hash = "sha256-eeRcGfGZD7Tg4psAK1IzKgpAkI5RcrBiqyADk0eTdLY=";
  };

  vendorHash = "sha256-u+nl3P7YNl+3DJIXo7pnDKF4PkoYLaHf3B1LqF9b+V8=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Declarative configuration management for Incus";
    homepage = "https://github.com/abiosoft/incus-apply";
    mainProgram = "incus-apply";
  };
}
