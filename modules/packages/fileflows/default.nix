{ lib
, stdenvNoCC
, fetchzip
, dotnetCorePackages
, sqlite
, libz
, writeShellScript
}:
let
  dotnet = dotnetCorePackages.aspnetcore_10_0;
  buildInputs = [
    sqlite
    libz
  ];

  server-script = writeShellScript "fileflows-server-unsubstituted.sh" ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"

    if [ -z "$FILEFLOWS_SERVER_BASE_DIR" ]; then
        echo "ERROR: Environment variable FILEFLOWS_SERVER_BASE_DIR is not defined"
        exit 1
    fi

    cd "$FILEFLOWS_SERVER_BASE_DIR"

    rm -rf Server Node Agent FlowRunner Libraries

    cp -r @OUT@/fileflows/Server .
    cp -r @OUT@/fileflows/Agent .
    cp -r @OUT@/fileflows/FlowRunner .
    cp -r @OUT@/fileflows/Libraries .
    chmod -R u+w Server Agent FlowRunner Libraries

    cd Server
    exec "${dotnet}/bin/dotnet" FileFlows.Server.dll "$@"
  '';

  node-script = writeShellScript "fileflows-node-unsubstituted.sh" ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"

    if [ -z "$FILEFLOWS_NODE_BASE_DIR" ]; then
      echo "ERROR: Environment variable FILEFLOWS_NODE_BASE_DIR is not defined"
      exit 1
    fi

    cd "$FILEFLOWS_NODE_BASE_DIR"

    rm -rf Node Agent FlowRunner Libraries

    cp -r @OUT@/fileflows/Agent .
    cp -r @OUT@/fileflows/FlowRunner .
    cp -r @OUT@/fileflows/Libraries .
    chmod -R u+w Agent FlowRunner Libraries

    cd Agent
    exec "${dotnet}/bin/dotnet" FileFlows.Agent.dll "$@"
  '';
in
stdenvNoCC.mkDerivation rec {
  pname = "fileflows";
  version = "26.10.3.8555";
  src = fetchzip {
    url = "https://fileflows.com/downloads/TarXz/${version}";
    extension = "tar.xz";
    hash = "sha256-50KhV6dK8jjABp/9jwxu7855eyVcvq3Uu1J1b1MFqmk=";
    stripRoot = false;
  };

  inherit buildInputs;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/fileflows
    cp -r ./ $out/fileflows

    mkdir $out/bin

    cp ${server-script} $out/bin/server
    cp ${node-script} $out/bin/node

    substituteInPlace $out/bin/server $out/bin/node --replace-fail @OUT@ $out
  '';

  meta = with lib; {
    description = "FileFlows server and node with wrapper scripts";
    homepage = "https://fileflows.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
