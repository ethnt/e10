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
    version = "1.6.2";
    source = fetchFromGitHub {
      owner = "rustmailer";
      repo = "bichon";
      rev = version;
      hash = "sha256-a8BAO93eI2eiFwmvMqUsgL1KZ11X3qg/r/Iw6ckMSTs=";
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
        fetcherVersion = 4;
        hash = "sha256-Ax8z1sjt8v6XOenhw7eRuEEo0huPv9fbcfzqc8RxJEc=";
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

    cargoHash = "sha256-GC/2bswme76bAFRCsBHFi3lWnYx5x5H58emCmkiyKfE=";

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
