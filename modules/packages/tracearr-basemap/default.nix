{ lib
, stdenvNoCC
, cacert
, curl
, jq
}:
let
  version = "3.1.3";
  layerDigest = "sha256:27d9ebd5d5831c08037dda64b034d860ec164206cb4b5f9566b4f2c71b7dfe0d";
in
stdenvNoCC.mkDerivation {
  pname = "tracearr-basemap";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [ curl jq ];

  impureEnvVars = lib.fetchers.proxyImpureEnvVars;

  buildCommand = ''
    curlOpts=(--silent --show-error --fail --location
      --cacert "${cacert}/etc/ssl/certs/ca-bundle.crt")

    token=$(curl "''${curlOpts[@]}" \
      "https://ghcr.io/token?scope=repository:connorgallopo%2Ftracearr:pull&service=ghcr.io" \
      | jq -r .token)

    curl "''${curlOpts[@]}" -H "Authorization: Bearer $token" \
      "https://ghcr.io/v2/connorgallopo/tracearr/blobs/${layerDigest}" \
      | gzip -d | tar -xO app/data/basemap.pmtiles > $out
  '';

  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = "sha256-9BqvkIB4X4vqfWbpWpMDv0379PycZnGtBkToIN+J2o8=";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "PMTiles vector basemap shipped in the Tracearr container image";
    homepage = "https://github.com/connorgallopo/Tracearr";
    license = lib.licenses.odbl;
    platforms = lib.platforms.all;
  };
}
