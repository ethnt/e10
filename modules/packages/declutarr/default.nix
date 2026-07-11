{ lib
, fetchFromGitHub
, makeWrapper
, python3Packages
,
}:

python3Packages.buildPythonApplication rec {
  name = "declutarr";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "ManiMatter";
    repo = "decluttarr";
    tag = "v${version}";
    hash = "sha256-pOuAQ2KKvhmUM6xX5iX9s33ZXL3OLx6yIOL8LZF1W64=";
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

  meta = with lib; {
    description = "Watches radarr, sonarr, lidarr, readarr and whisparr download queues and removes downloads if they become stalled or no longer needed.";
    homepage = "https://github.com/ManiMatter/decluttarr";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "declutarr";
  };
}
