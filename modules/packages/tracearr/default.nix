{ lib
, stdenv
, pnpm_12
, fetchPnpmDeps
, pnpmConfigHook
, makeWrapper
, nodejs
, fetchFromGitHub
, turbo
, nix-update-script
}:
let pnpm = pnpm_12; in
stdenv.mkDerivation (finalAttrs: {
  pname = "tracearr";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "connorgallopo";
    repo = "Tracearr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5iYCMUSuDg5iqOCFoVh4jHAymPkXlu3X3VMFKGXee8c=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-u1/mfBG+IxXQdKaTdCWeIwGKl4Eo1aMq7uMhachfef4=";
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

  # `pnpm run build` just calls `turbo build`, but Turbo's default strict env
  # mode drops the `pnpm_config_pm_on_fail=ignore` that `pnpmConfigHook` exports.
  # Without it, the `pnpm run build` that Turbo spawns per workspace tries to
  # fetch the pnpm version pinned in `package.json` and dies offline. Calling
  # Turbo directly lets us pass `--env-mode=loose` so the setting survives.
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
      --set-default APP_VERSION ${finalAttrs.version} \
      --set-default APP_TAG v${finalAttrs.version} \
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
})
