{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "mazaonke";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "civilblur";
    repo = "mazanoke";
    tag = "v${version}";
    hash = "sha256-cBGk2SYQs53jA9luHp/lc4aWpu83pcbLp7dBnkvBIT8=";
  };

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/share/mazanoke
    cp ./index.html ./favicon.ico ./manifest.json ./service-worker.js $out/share/mazanoke
    cp -r ./assets $out/share/mazanoke/assets

    runHook postBuild
  '';
}
