{ stdenvNoCC, fetchurl, unzip }:

stdenvNoCC.mkDerivation rec {
  pname = "grafana-postgresql-datasource";
  version = "13.0.4";

  src = fetchurl {
    name = "${pname}-${version}.zip";
    url = "https://grafana.com/api/plugins/${pname}/versions/${version}/download";
    hash = "sha256-4Mn3tWAin9eLcB+oA1UhJ9tKq0Z7sDbVBtjRJMYsf+s=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    cp -R "." "$out"
    chmod -R a-w "$out"
    chmod u+w "$out"
  '';
}
