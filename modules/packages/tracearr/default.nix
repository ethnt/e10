{ lib
, stdenv
, pnpm_12
, fetchPnpmDeps
, pnpmConfigHook
, makeWrapper
, nodejs-slim_22
, fetchFromGitHub
, turbo
, nix-update-script
}:
let
  pnpm = pnpm_12.override { nodejs-slim = nodejs-slim_22; };
  nodejs = nodejs-slim_22;
in
stdenv.mkDerivation rec {
  pname = "tracearr";
  version = "3.1.3";

  src = fetchFromGitHub {
    owner = "connorgallopo";
    repo = "Tracearr";
    tag = "v${version}";
    hash = "sha256-EvnD2wqrI/32GRVQQsWAfaL6ptn/tVezafMxNWKpcUA=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-wxtx5Jdx2eSSo+OR6284/4cWbqrlO1kXXknhK06FVaw=";
  };

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

    turbo build --env-mode=loose

    runHook postBuild
  '';

  doCheck = false;

  checkPhase = ''
    runHook preCheck

    turbo test --env-mode=loose

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
      --set-default APP_VERSION ${version} \
      --set-default APP_TAG v${version} \
      --set-default NODE_ENV production

    runHook postInstall
  '';

  postInstall = ''
    find $out/lib -xtype l -delete
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Real-time monitoring for Plex, Jellyfin, and Emby servers. Track streams, analyze playback, and detect account sharing from a single dashboard.";
    mainProgram = "tracearr";
    homepage = "https://tracearr.com";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = [
      {
        name = "Ethan Turkeltaub";
        github = "ethnt";
        githubId = 137037;
      }
    ];
  };
}
