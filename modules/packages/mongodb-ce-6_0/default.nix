{ stdenv, lib, fetchurl, autoPatchelfHook, curl, openssl, lz4, xz, }:

let
  version = "6.0.17";

  srcs = version: {
    "x86_64-linux" = {
      url =
        "https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2204-${version}.tgz";
      hash = "sha256-zZ1ObTLo15UNxCjck56LWMrf7FwRapYKCwfU+LeUmi0=";
    };
  };
in
stdenv.mkDerivation (_finalAttrs: {
  pname = "mongodb-ce-6_0";
  inherit version;

  src = fetchurl (
    (srcs version).${stdenv.hostPlatform.system} or (throw
      "unsupported system: ${stdenv.hostPlatform.system}")
  );

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  dontStrip = true;

  buildInputs = [ curl.dev openssl.dev stdenv.cc.cc.lib lz4 xz ];

  installPhase = ''
    runHook preInstall

    install -Dm 755 bin/mongod $out/bin/mongod
    install -Dm 755 bin/mongos $out/bin/mongos

    runHook postInstall
  '';
})
