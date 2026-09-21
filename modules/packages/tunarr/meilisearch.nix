{ lib
, stdenv
, fetchurl
, patchelf
, autoPatchelfHook
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "meilisearch-tunarr";
  version = "1.30.0";

  src = fetchurl {
    url = "https://github.com/meilisearch/meilisearch/releases/download/v${finalAttrs.version}/meilisearch-linux-amd64";
    hash = "sha256-T3Lxaep95qBLODvfltt0PeTqxpQ2BUBQ/xXshwP1B+E=";
  };

  dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook patchelf ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/meilisearch
    runHook postInstall
  '';

  meta = {
    description = "Meilisearch build pinned to the version Tunarr expects";
    homepage = "https://www.meilisearch.com";
    license = lib.licenses.mit;
    mainProgram = "meilisearch";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
