{ lib, rustPlatform, fetchFromGitLab, nix-update-script }:

rustPlatform.buildRustPackage rec {
  pname = "glitchtip-cli";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "glitchtip";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-cdWGTcrssU+kOwX8n2ECsgbnpDOFTDWjJBSYys4YkEU=";
  };

  cargoHash = "sha256-hSUUTbKPZKfS1n+iBRlYgQoOfeU+oHxDM6BysQmg2x4=";

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Command-line tool for interacting with GlitchTip";
    homepage = "https://gitlab.com/glitchtip/glitchtip-cli";
    license = licenses.mit;
    mainProgram = "glitchtip-cli";
  };
}
