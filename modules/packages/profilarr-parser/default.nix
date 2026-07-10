{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:

buildDotnetModule rec {
  pname = "profilarr-parser";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "Dictionarry-Hub";
    repo = "Profilarr";
    tag = "v${version}";
    hash = "sha256-tpgTeKJCeEfhoARpq5u9W8iFZNocTNOhihAJNsyfTLY=";
  };

  sourceRoot = "${src.name}/src/services/parser";

  projectFile = "Parser.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  preConfigure = ''
    rm -f Directory.Build.props
  '';

  executables = [ "Parser" ];

  postFixup = ''
    mv $out/bin/Parser $out/bin/profilarr-parser
  '';

  meta = {
    description = "Release title parser microservice for Profilarr";
    homepage = "https://github.com/Dictionarry-Hub/Profilarr";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "profilarr-parser";
  };
}
