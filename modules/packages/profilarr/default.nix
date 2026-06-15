{ lib, stdenv, fetchFromGitHub, deno, cacert, makeWrapper, autoPatchelfHook
, sqlite, git }:

let
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "Dictionarry-Hub";
    repo = "Profilarr";
    tag = "v${version}";
    hash = "sha256-tpgTeKJCeEfhoARpq5u9W8iFZNocTNOhihAJNsyfTLY=";
  };

  denoDeps = stdenv.mkDerivation {
    pname = "profilarr-deno-deps";
    inherit version src;

    nativeBuildInputs = [ deno cacert sqlite ];

    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    DENO_SQLITE_PATH = "${sqlite.out}/lib/libsqlite3${stdenv.hostPlatform.extensions.sharedLibrary}";

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR
      export DENO_DIR=$TMPDIR/deno-dir
      export DENO_NO_UPDATE_CHECK=1

      deno install --node-modules-dir --allow-scripts=npm:esbuild

      # Populate the deno cache (DENO_DIR/plug) with native FFI libraries
      # (e.g. @felix/bcrypt) that get downloaded on first use during the
      # build, so the offline build below can reuse them.
      APP_BASE_PATH=./dist/build deno run -A npm:vite build

      # Cache the remote (jsr:) dependencies of the generated entrypoint,
      # which aren't covered by deno.lock since it's generated at build time.
      deno cache dist/build/mod.ts

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r node_modules $out/node_modules
      cp -r $DENO_DIR $out/deno-dir

      runHook postInstall
    '';

    dontFixup = true;

    outputHashMode = "recursive";
    outputHash = {
      x86_64-linux = "sha256-9HjICCAYDpnGT/1vCZdOF8UTBjPosWYvIYr2uOQbmRs=";
      aarch64-linux = "sha256-viZIFv4CDXdYaB7lisLkkiLnyWkrFsL2fjsLs8J7hN4=";
    }.${stdenv.hostPlatform.system} or (throw
      "profilarr: unsupported system ${stdenv.hostPlatform.system}");
  };

in stdenv.mkDerivation (finalAttrs: {
  pname = "profilarr";
  inherit version src;

  nativeBuildInputs = [ deno makeWrapper autoPatchelfHook cacert ];
  buildInputs = [ stdenv.cc.cc.lib sqlite ];

  # musl-targeted native addons are bundled alongside the glibc ones that are
  # actually used at runtime; they can never be satisfied on NixOS.
  autoPatchelfIgnoreMissingDeps =
    [ "libc.musl-x86_64.so.1" "libc.musl-aarch64.so.1" ];

  DENO_SQLITE_PATH = "${sqlite.out}/lib/libsqlite3${stdenv.hostPlatform.extensions.sharedLibrary}";

  # The app runs on Deno itself rather than as a compiled standalone binary,
  # so the runtime is the nixpkgs `deno` package (already patched for NixOS)
  # and only the source tree plus its dependencies need to be installed.
  postPatch = ''
    substituteInPlace svelte.config.js \
      --replace-fail "usage: 'deno-compile'," "usage: 'deno',"
  '';

  configurePhase = ''
    runHook preConfigure

    cp -r ${denoDeps}/node_modules .
    chmod -R u+w node_modules

    export DENO_DIR=$TMPDIR/deno-dir
    cp -r ${denoDeps}/deno-dir $DENO_DIR
    chmod -R u+w $DENO_DIR

    export DENO_NO_UPDATE_CHECK=1
    export HOME=$TMPDIR

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    APP_BASE_PATH=./dist/build deno run -A --cached-only npm:vite build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/profilarr $out/bin $out/share
    cp -r node_modules dist src static deno.json deno.lock package.json \
      tsconfig.json svelte.config.js vite.config.ts $out/lib/profilarr/
    cp -r $DENO_DIR $out/share/deno-dir

    makeWrapper ${lib.getExe deno} $out/bin/profilarr \
      --run "cd $out/lib/profilarr" \
      --add-flags "run -A dist/build/mod.ts" \
      --prefix PATH : ${lib.makeBinPath [ git ]} \
      --set-default DENO_DIR "$out/share/deno-dir" \
      --set-default DENO_NO_UPDATE_CHECK 1 \
      --set-default DENO_SQLITE_PATH "$DENO_SQLITE_PATH" \
      --set-default SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"

    runHook postInstall
  '';

  meta = {
    description = "Configuration management for Radarr and Sonarr";
    homepage = "https://github.com/Dictionarry-Hub/Profilarr";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "profilarr";
  };
})
