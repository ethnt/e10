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

let
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "rustmailer";
    repo = "bichon";
    rev = version;
    hash = "sha256-0RBMkm5qUnc18JLJ3mRcLgtk9YjKsrMJCmaRat/7wUo=";
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "bichon-frontend";
    inherit version src;

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
rustPlatform.buildRustPackage {
  pname = "bichon";
  inherit version src;

  cargoHash = "sha256-F2zuAh9mPdpZUAHvbRTPN0bTTaaBI77goEIjgjkfMXc=";

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

  passthru.frontend = frontend;

  meta = with lib; {
    description = "Lightweight, high-performance Rust email archiver with WebUI";
    homepage = "https://github.com/rustmailer/bichon";
    license = licenses.agpl3Plus;
    platforms = platforms.linux;
    mainProgram = "bichon-server";
  };
}
