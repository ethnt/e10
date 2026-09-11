{ lib, pkgs }:
let
  imageVersion = "c9603dec9010";
  installerVersion = "5.1.42";
  url = "https://fw-download.ubnt.com/data/unifi-os-server/5172-linux-x64-5.1.42-12e9e3cf-8f8b-4e54-928c-76b80a10c8a4.42-x64";
  sha256 = "sha256-9hEek5akLHQBb13emwH770hqb+ae/hN5Nebji3wi+U0=";
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "unifi-os-server";
  version = installerVersion;

  src = pkgs.fetchurl { inherit url sha256; };

  nativeBuildInputs = with pkgs; [
    binwalk
    coreutils
    findutils
  ];

  dontUnpack = true;

  installPhase = ''
    set -euo pipefail

    runHook preInstall

    work="$PWD/work"
    mkdir -p "$work"

    cp "$src" "$work/unifi-os-installer"
    chmod u+w "$work/unifi-os-installer"

    cd "$work"

    binwalk --threads 1 -e ./unifi-os-installer >/dev/null

    image_tar="$(find . -type f -name image.tar | head -n1)"
    if [ -z "$image_tar" ]; then
      echo "Could not find embedded image.tar in UniFi OS installer" >&2
      exit 1
    fi

    mkdir -p "$out"
    tar -xf "$image_tar" -C "$out"
    cp "$image_tar" "$out/image.tar"

    runHook postInstall
  '';

  passthru.imageTag = "uosserver:${imageVersion}";
  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "UniFi OS Server installer package";
    homepage = "https://help.ui.com/hc/en-us/articles/34210126298775-Self-Hosting-UniFi";
    license = licenses.unfree;
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
