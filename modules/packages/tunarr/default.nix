{ lib
, stdenv
, fetchurl
, makeWrapper
, patchelf
, ffmpeg
, nix-update-script
}:
let
  version = "1.3.13";
in
stdenv.mkDerivation {
  pname = "tunarr";
  inherit version;

  src = fetchurl {
    url = "https://github.com/chrisbenincasa/tunarr/releases/download/v${version}/tunarr-v${version}-linux-x64.tar.gz";
    hash = "sha256-F3iHt11oN+IxPo80s/sMzuxCz+8muFbSPULnMpXmDkY=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [
    makeWrapper
    patchelf
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 tunarr-v${version}-linux-x64 "$out/libexec/tunarr/tunarr"
    install -Dm755 meilisearch "$out/bin/meilisearch"

    # Tunarr is a pkg single-file executable with an appended payload, so
    # patchelf would corrupt its internal offsets. Run it through nix-ld and
    # patch only the ordinary Meilisearch ELF.
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${lib.makeLibraryPath [stdenv.cc.cc.lib stdenv.cc.libc]}" \
      "$out/bin/meilisearch"

    makeWrapper "$out/libexec/tunarr/tunarr" "$out/bin/tunarr" \
      --set NIX_LD "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set NIX_LD_LIBRARY_PATH "${lib.makeLibraryPath [stdenv.cc.cc.lib stdenv.cc.libc]}" \
      --prefix PATH : "${lib.makeBinPath [ffmpeg]}" \
      --set-default TUNARR_MEILISEARCH_PATH "$out/bin/meilisearch"

    runHook postInstall
  '';

  passthru.ffmpeg = ffmpeg;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Create classic TV channels from personal media libraries";
    homepage = "https://tunarr.com";
    license = lib.licenses.zlib;
    mainProgram = "tunarr";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
