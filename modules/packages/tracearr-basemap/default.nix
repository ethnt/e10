{ lib
, stdenvNoCC
, cacert
, curl
, jq
}:
let
  version = "2.5.1";
  layerDigest = "sha256:d868e99732f6791773b24937553e945939259ac914ccabb1d40ea541c39e2742";
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
  outputHash = "sha256-wR5seDnILvAT8GI8g0RQbcbVcftSLcL694EHbWCqiLI=";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "PMTiles vector basemap shipped in the Tracearr container image";
    homepage = "https://github.com/connorgallopo/Tracearr";
    license = lib.licenses.odbl;
    platforms = lib.platforms.all;
  };
}
