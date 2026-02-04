{ lib, stdenv, pnpm_9, fetchPnpmDeps, pnpmConfigHook, makeWrapper, nodejs
, fetchFromGitHub, }:
stdenv.mkDerivation (finalAttrs: {
  pname = "tracearr";
  version = "1.4.12";

  src = fetchFromGitHub {
    owner = "connorgallopo";
    repo = "Tracearr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KE/kMB620+Eksq21uaqzEeoQVIlJN2cEEkJVh9/ccBE=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_9;
    fetcherVersion = 1;
    hash = "sha256-xI940Bjv5O543yTAQdfgM7UbOpXNhb1rvI90G+BvecE=";
  };

  nativeBuildInputs = [ pnpmConfigHook pnpm_9 makeWrapper ];

  buildInputs = [ nodejs ];

  buildPhase = ''
    runHook preBuild
    NODE_ENV="production" pnpm run build --filter=@tracearr/shared --filter=@tracearr/server --filter=@tracearr/web
    runHook postBuild
  '';

  preInstall = ''
    rm node_modules/.modules.yaml
    find -type f \( -name "*.d.ts" -o -name "*.map" \) -exec rm -rf {} +
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{share/tracearr,bin}

    cp -r {node_modules,apps,packages} $out/share/tracearr

    makeWrapper ${lib.getExe nodejs} $out/bin/tracearr \
      --add-flags $out/share/tracearr/apps/server/dist/index.js \
      --set NODE_PATH "$out/share/tracearr/node_modules:$out/share/tracearr/apps/server/node_modules:$out/share/tracearr/apps/web/node_modules" \
      --set-default NODE_ENV production

    find $out/share -xtype l -delete

    runHook postInstall
  '';

  meta = {
    description =
      "Real-time monitoring for Plex, Jellyfin, and Emby servers. Track streams, analyze playback, and detect account sharing from a single dashboard.";
    homepage = "https://tracearr.com";
    license = lib.licenses.agpl3Only;
  };
})
