{ lib
, stdenv
, fetchFromGitHub
, fetchPnpmDeps
, pnpm_11
, pnpmConfigHook
, nodejs_22
, node-gyp
, makeWrapper
, python3
, ffmpeg
, callPackage
, nix-update-script
}:
let
  nodejs = nodejs_22;
  pnpm = pnpm_11;
  nodeGyp = node-gyp.override { nodejs = nodejs_22; };
  meilisearch = callPackage ./meilisearch.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tunarr";
  version = "1.3.15";

  src = fetchFromGitHub {
    owner = "chrisbenincasa";
    repo = "tunarr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8ClWs3cTD0ABbuXthu5/emxOMXZExfTNhWGtWV33pOo=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-xZUqsIMGVu9sGeTz6WNpcZbid1ueQmXwpKbNw79Al5M=";
  };

  postPatch = ''
    sed -i 's|"packageManager": "pnpm@[^"]*"|"packageManager": "pnpm@${pnpm.version}"|' package.json
  '';

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpmConfigHook
    pnpm
    nodeGyp
    python3
  ];

  buildInputs = [ nodejs ];

  env = {
    TUNARR_VERSION = finalAttrs.version;
    TUNARR_EDGE_BUILD = "false";
    TURBO_CONCURRENCY = "1";
    TURBO_TELEMETRY_DISABLED = "1";
    npm_config_nodedir = "${nodejs}";
    npm_config_build_from_source = "true";
  };

  buildPhase = ''
    runHook preBuild

    for d in . server web; do
      printf 'TUNARR_VERSION=%s\nTUNARR_BUILD=\nTUNARR_EDGE_BUILD=false\n' \
        "${finalAttrs.version}" > "$d/.env"
    done

    echo "Building better-sqlite3 native addon..."
    ( cd node_modules/.pnpm/better-sqlite3@*/node_modules/better-sqlite3
      node-gyp rebuild --release )

    pnpm exec turbo run bundle

    cp -r web/dist server/dist/web
    cp -r server/src/migration/db/sql server/dist/sql

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/tunarr $out/bin
    cp -r server/dist/. $out/lib/tunarr/

    makeWrapper ${lib.getExe nodejs} $out/bin/tunarr \
      --add-flags $out/lib/tunarr/bundle.cjs \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]} \
      --set-default TUNARR_MEILISEARCH_PATH ${lib.getExe meilisearch} \
      --set-default NODE_ENV production

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit ffmpeg meilisearch;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Create classic TV channels from personal media libraries";
    homepage = "https://tunarr.com";
    license = lib.licenses.zlib;
    mainProgram = "tunarr";
    platforms = lib.platforms.linux;
    maintainers = [
      {
        name = "Ethan Turkeltaub";
        github = "ethnt";
        githubId = 137037;
      }
    ];
  };
})
