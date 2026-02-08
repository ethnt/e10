{ python3Packages, fetchFromGitHub, makeWrapper }:

python3Packages.buildPythonApplication rec {
  name = "declutarr";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "ManiMatter";
    repo = "decluttarr";
    tag = "v${version}";
    hash = "sha256-3mB5+ao3w+CkyTS/o1O9/7UXOoGkA/mTpJNEQxUTa9Q=";
  };

  pyproject = true;

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    requests
    python-dateutil
    pytest
    pytest-asyncio
    black
    pylint
    autoflake
    isort
    pyyaml-env-tag
    demjson3
    ruff
    watchdog
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec/declutarr
    cp -R main.py src tests $out/libexec/declutarr

    makeWrapper "${python3Packages.python.interpreter}" "$out/bin/declutarr" \
      --set PYTHONPATH "$PYTHONPATH" \
      --add-flags "$out/libexec/declutarr/main.py"

    runHook postInstall
  '';

  # TODO: Actually run tests
  doCheck = false;

  meta.mainProgram = "declutarr";
}
