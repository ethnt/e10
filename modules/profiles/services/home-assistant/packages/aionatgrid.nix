{ buildPythonPackage, fetchFromGitHub, setuptools, aiohttp, typing-extensions
, pyjwt }:

buildPythonPackage rec {
  pname = "aionatgrid";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "RyanMorash";
    repo = "aionatgrid";
    tag = "v${version}";
    hash = "sha256-HhsB6KmdaRNxgE08kNKMTg3wZWZe86cz7sBbwUR79P4=";
  };

  doCheck = false;

  pyproject = true;
  build-system = [ setuptools ];

  dependencies = [ aiohttp typing-extensions pyjwt ];
}
