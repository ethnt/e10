{ lib
, stdenv
, pnpm
, fetchPnpmDeps
, pnpmConfigHook
, makeWrapper
, nodejs
, fetchFromGitHub
, turbo
,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tracearr";
  version = "1.4.31";

  src = fetchFromGitHub {
    owner = "connorgallopo";
    repo = "Tracearr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jsCKZ0HKHZ3YkLx1kruvSp/MOsP74Lr8TRXsVMQPlv8=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-8K20khCKaTHYC9r/TfWldoN+53XcueSVlFfd4G6K9vU=";
  };

  # The pnpm version is required, but nixpkgs doesn't provide the exact version that Tracearr requires
  # We can fudge this by replacing the version in the `package.json` with the one we have
  postPatch = ''
    sed -i 's|"packageManager": "pnpm@[^"]*"|"packageManager": "pnpm@${pnpm.version}"|' package.json
  '';

  strictDeps = true;

  env.NODE_ENV = "production";

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpmConfigHook
    pnpm
    turbo
  ];

  buildInputs = [ nodejs ];

  buildPhase = ''
    runHook preBuild
    pnpm run build
    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    pnpm test

    runHook postCheck
  '';

  preInstall = ''
    find . -type f \( -name "*.d.ts" -o -name "*.map" \) -delete
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{lib/tracearr,bin}
    cp -r {node_modules,apps,packages,data} $out/lib/tracearr
    makeWrapper ${lib.getExe nodejs} $out/bin/tracearr \
      --add-flags $out/lib/tracearr/apps/server/dist/index.js \
      --set NODE_PATH "$out/lib/tracearr/node_modules:$out/lib/tracearr/apps/server/node_modules:$out/lib/tracearr/apps/web/node_modules" \
      --set-default APP_VERSION ${finalAttrs.version} \
      --set-default APP_TAG v${finalAttrs.version} \
      --set-default NODE_ENV production

    runHook postInstall
  '';

  postInstall = ''
    find $out/lib -xtype l -delete
  '';

  meta = {
    description = "Real-time monitoring for Plex, Jellyfin, and Emby servers. Track streams, analyze playback, and detect account sharing from a single dashboard.";
    mainProgram = "tracearr";
    homepage = "https://tracearr.com";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ ethnt ];
  };
})
