{ lib, pkgs }:
let
  imageVersion = "f77bca81ecbf";
  installerVersion = "5.1.15";
  url = "https://fw-download.ubnt.com/data/unifi-os-server/24e0-linux-x64-5.1.15-926621de-c9d7-48cd-8921-a0ff3eebd3f4.15-x64";
  sha256 = "sha256-BMjkAes0Mw/pnZTzWqNR4ODpeJXw2aS0Wf80+1DK0rs=";

  # TODO: Can remove when this fix is merged
  # https://github.com/nixos/nixpkgs/pull/530407
  binwalk = pkgs.binwalk.override {
    uefi-firmware-parser = pkgs.python3Packages.uefi-firmware-parser.overridePythonAttrs (old: {
      build-system = (old.build-system or [ ]) ++ [ pkgs.python3Packages.setuptools-scm ];
    });
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "unifi-os-server";
  version = installerVersion;

  src = pkgs.fetchurl { inherit url sha256; };

  nativeBuildInputs = [
    binwalk
  ]
  ++ (with pkgs; [
    coreutils
    findutils
  ]);

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

  meta = with lib; {
    description = "UniFi OS Server installer package";
    homepage = "https://help.ui.com/hc/en-us/articles/34210126298775-Self-Hosting-UniFi";
    license = licenses.unfree;
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
