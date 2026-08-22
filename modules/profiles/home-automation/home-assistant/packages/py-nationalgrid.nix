{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  aiohttp,
  pyjwt,
}:

buildPythonPackage rec {
  pname = "py-nationalgrid";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "virtitnerd";
    repo = "py-nationalgrid";
    tag = "v${version}";
    hash = "sha256-Gbhpd4Ym2MVM+GLLEvGd7gLEEzLQmMegMoKQ8LvrsAI=";
  };

  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = false;

  pyproject = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    pyjwt
  ];
}
