{ lib, pkgs }:
let
  imageVersion = "d7bbd4816078";
  installerVersion = "5.1.37";
  url = "https://fw-download.ubnt.com/data/unifi-os-server/9aee-linux-x64-5.1.37-a88d909c-2ac0-43f8-bb22-2bff3b673cbb.37-x64";
  sha256 = "sha256-SlsffynyVzPPxfdJemPj29T0phazUsu9gXqJ6x+ma2E=";
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
