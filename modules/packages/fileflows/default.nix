{ lib, stdenvNoCC, fetchzip, dotnetCorePackages, sqlite, libz, writeShellScript
}:
let
  version = "26.4.9.6710";

  dotnet = dotnetCorePackages.aspnetcore_8_0;
  buildInputs = [ sqlite libz ];

  server-script = writeShellScript "fileflows-server-unsubstituted.sh" ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"

    if [ -z "$FILEFLOWS_SERVER_BASE_DIR" ]; then
        echo "ERROR: Environment variable FILEFLOWS_SERVER_BASE_DIR is not defined"
        exit 1
    fi

    cd "$FILEFLOWS_SERVER_BASE_DIR"

    cp -r @OUT@/fileflows/Server .
    cp -r @OUT@/fileflows/Node .
    cp -r @OUT@/fileflows/FlowRunner .
    chmod -R u+w Server Node FlowRunner

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

    cp -r @OUT@/fileflows/Node .
    cp -r @OUT@/fileflows/FlowRunner .
    chmod -R u+w Node FlowRunner

    cd Node
    exec "${dotnet}/bin/dotnet" FileFlows.Node.dll "$@"
  '';
in stdenvNoCC.mkDerivation rec {
  pname = "fileflows";
  inherit version;

  src = fetchzip {
    url = "https://fileflows.com/downloads/Zip/${version}";
    extension = "zip";
    hash = "sha256-rKNfhMb4saR9ae7V1/JW2xQHcWcjySXi1fqJpunVFTs=";
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

  meta = {
    description = "FileFlows server and node with wrapper scripts";
    homepage = "https://fileflows.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
