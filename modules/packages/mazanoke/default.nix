{ stdenv, fetchFromGitHub, nix-update-script }:

stdenv.mkDerivation rec {
  pname = "mazaonke";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "civilblur";
    repo = "mazanoke";
    tag = "v${version}";
    hash = "sha256-3w3iJvLyykbzuw+rpoGPpv7doYN+jecENg85VgYS5Fw=";
  };

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/share/mazanoke
    cp ./index.html ./favicon.ico ./manifest.json ./service-worker.js $out/share/mazanoke
    cp -r ./assets $out/share/mazanoke/assets

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };
}
