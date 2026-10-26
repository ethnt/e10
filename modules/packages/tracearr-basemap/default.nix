{ lib
, stdenvNoCC
, cacert
, curl
, jq
}:
let
  version = "3.1.1";
  layerDigest = "sha256:b591c5bbc42208b5d6a4e35fac0b08f40d5a408199543b7daa53552a41544fbc";
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
  outputHash = "sha256-nMMtnZo3Q+Ht8g7IktTvTS0GCZKu/CFcDm+cN+3lt6o=";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "PMTiles vector basemap shipped in the Tracearr container image";
    homepage = "https://github.com/connorgallopo/Tracearr";
    license = lib.licenses.odbl;
    platforms = lib.platforms.all;
  };
}
