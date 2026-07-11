{ stdenv
, lib
, rustPlatform
, fetchFromGitHub
, fetchPnpmDeps
, nodejs_22
, pnpm
, pnpmConfigHook
, typescript
, pkg-config
, git
, openssl
,
}:

rustPlatform.buildRustPackage (
  let
    pname = "bichon";
    version = "1.5.2";
    source = fetchFromGitHub {
      owner = "rustmailer";
      repo = "bichon";
      rev = version;
      hash = "sha256-QvAUM1fncnbmXGJ4fhq7c4ZvE4rquMQqdqq6RlOIBxI=";
    };
    frontend = stdenv.mkDerivation (finalAttrs: {
      pname = "${pname}-frontend";
      inherit version;

      src = source;

      sourceRoot = "${finalAttrs.src.name}/web";

      nativeBuildInputs = [
        nodejs_22
        pnpm
        pnpmConfigHook
        typescript
      ];

      pnpmDeps = fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        fetcherVersion = 3;
        hash = "sha256-7EkSYTUXOtYewvOoKJiOSNmpowJj27/Ea8PAcebJCzA=";
        sourceRoot = "${finalAttrs.src.name}/web";
      };

      patchPhase = ''
        export CI=true
      '';

      buildPhase = ''
        runHook preBuild

        pnpm build

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -r dist $out/

        runHook postInstall
      '';
    });
  in
  {
    inherit pname version;

    src = source;

    cargoHash = "sha256-keEOzDf2DSOC2g8mLMuZhi1FwCaBXzo1yk0WmIcTFuI=";

    nativeBuildInputs = [
      pkg-config
      git
    ];

    buildInputs = [ openssl ];

    preBuild = ''
      mkdir -p web
      cp -r "${frontend}/dist" web/dist
    '';

    doCheck = false;

    meta = with lib; {
      description = "Lightweight, high-performance Rust email archiver with WebUI";
      homepage = "https://github.com/rustmailer/bichon";
      license = licenses.agpl3Plus;
      platforms = platforms.linux;
      mainProgram = "bichon-server";
    };
  }
)
